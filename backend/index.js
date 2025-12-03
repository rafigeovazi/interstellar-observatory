const express = require("express");
const { Pool } = require("pg");
const cors = require("cors");
const bodyParser = require("body-parser");
require("dotenv").config();

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(bodyParser.json());

const poolConfig = (() => {
  if (process.env.DATABASE_URL) {
    return {
      connectionString: process.env.DATABASE_URL,
      // Supabase/Railway require TLS; allow opt-out only when explicitly disabled.
      ssl:
        process.env.DATABASE_SSL === "disable"
          ? false
          : { rejectUnauthorized: false },
    };
  }

  return {
    user: process.env.DB_USER || "postgres",
    host: process.env.DB_HOST || "localhost",
    database: process.env.DB_NAME || "interstellar_db",
    password: process.env.DB_PASSWORD || "postgres",
    port: Number(process.env.DB_PORT) || 5432,
  };
})();

const pool = new Pool(poolConfig);

const baseSelect = `
  SELECT
    ao.id,
    ao.name,
    ao.type,
    ao.magnitude,
    ao.temperature_kelvin,
    ao.distance_light_years,
    ao.solar_mass,
    ao.is_habitable,
    ao.created_at,
    sd.spectral_class,
    sd.luminosity,
    sd.radius_solar,
    d.discovery_date,
    d.discovery_method,
    COALESCE(
      json_agg(
        DISTINCT jsonb_build_object(
          'name', disc.name,
          'nationality', disc.nationality,
          'birth_year', disc.birth_year
        )
      ) FILTER (WHERE disc.id IS NOT NULL),
      '[]'
    ) AS discoverers,
    primary_photo.url AS primary_photo_url,
    primary_photo.caption AS primary_photo_caption
  FROM AstronomicalObject ao
  LEFT JOIN StarDetails sd ON sd.object_id = ao.id
  LEFT JOIN LATERAL (
    SELECT id, discovery_date, discovery_method
    FROM Discovery
    WHERE object_id = ao.id
    ORDER BY discovery_date NULLS LAST, id ASC
    LIMIT 1
  ) d ON true
  LEFT JOIN DiscoveryDiscoverer dd ON dd.discovery_id = d.id
  LEFT JOIN Discoverer disc ON disc.id = dd.discoverer_id
  LEFT JOIN LATERAL (
    SELECT url, caption
    FROM Photo
    WHERE object_id = ao.id
    ORDER BY is_primary DESC, taken_date DESC NULLS LAST
    LIMIT 1
  ) primary_photo ON true
`;

const groupClause = `
  GROUP BY
    ao.id,
    sd.spectral_class,
    sd.luminosity,
    sd.radius_solar,
    d.discovery_date,
    d.discovery_method,
    primary_photo.url,
    primary_photo.caption
`;

const buildObjectsQuery = (filters) => {
  return `${baseSelect}${filters}${groupClause} ORDER BY ao.name ASC`;
};

app.get("/objects", async (req, res) => {
  try {
    const clauses = [];
    const params = [];

    if (req.query.type) {
      params.push(req.query.type);
      clauses.push(`ao.type = $${params.length}`);
    }

    if (req.query.habitable) {
      const isHabitable = req.query.habitable.toLowerCase() === "true";
      params.push(isHabitable);
      clauses.push(`ao.is_habitable = $${params.length}`);
    }

    if (req.query.search) {
      params.push(`%${req.query.search}%`);
      clauses.push(`LOWER(ao.name) LIKE LOWER($${params.length})`);
    }

    let filters = "";

    if (clauses.length > 0) {
      filters = ` WHERE ${clauses.join(" AND ")}`;
    }

    const query = buildObjectsQuery(filters);
    const { rows } = await pool.query(query, params);

    res.json(rows);
  } catch (error) {
    console.error("Error fetching objects:", error);
    res.status(500).json({ message: "Error fetching objects" });
  }
});

app.get("/objects/:id", async (req, res) => {
  const { id } = req.params;

  try {
    const query = buildObjectsQuery(" WHERE ao.id = $1");
    const { rows } = await pool.query(query, [id]);

    if (rows.length === 0) {
      return res.status(404).json({ message: "Object not found" });
    }

    const object = rows[0];

    const [photosResult, observationsResult, discoveriesResult] =
      await Promise.all([
        pool.query(
          `SELECT id, url, caption, taken_date, telescope, instrument, wavelength_filter, is_primary
         FROM Photo
         WHERE object_id = $1
         ORDER BY is_primary DESC, taken_date DESC NULLS LAST, id ASC`,
          [id]
        ),
        pool.query(
          `SELECT
            o.id,
            obs.name AS observatory_name,
            obs.location,
            obs.country,
            obs.established_year,
            o.observation_date,
            o.instrument,
            o.wavelength,
            o.exposure_time,
            o.notes
         FROM Observation o
         JOIN Observatory obs ON obs.id = o.observatory_id
         WHERE o.object_id = $1
         ORDER BY o.observation_date DESC NULLS LAST, o.id ASC`,
          [id]
        ),
        pool.query(
          `SELECT
            d.id,
            d.discovery_date,
            d.discovery_method,
            d.notes,
            COALESCE(
              json_agg(
                DISTINCT jsonb_build_object(
                  'id', disc.id,
                  'name', disc.name,
                  'nationality', disc.nationality,
                  'birth_year', disc.birth_year
                )
              ) FILTER (WHERE disc.id IS NOT NULL),
              '[]'
            ) AS discoverers
         FROM Discovery d
         LEFT JOIN DiscoveryDiscoverer dd ON dd.discovery_id = d.id
         LEFT JOIN Discoverer disc ON disc.id = dd.discoverer_id
         WHERE d.object_id = $1
         GROUP BY d.id
         ORDER BY d.discovery_date DESC NULLS LAST, d.id ASC`,
          [id]
        ),
      ]);

    res.json({
      ...object,
      photos: photosResult.rows,
      observations: observationsResult.rows,
      discoveries: discoveriesResult.rows,
    });
  } catch (error) {
    console.error("Error fetching object detail:", error);
    res.status(500).json({ message: "Error fetching object detail" });
  }
});

app.get("/discoverers", async (_req, res) => {
  try {
    const { rows } = await pool.query(`
      SELECT
        disc.id,
        disc.name,
        disc.nationality,
        disc.birth_year,
        disc.bio,
        COUNT(DISTINCT dd.discovery_id) AS total_discoveries,
        COALESCE(
          json_agg(
            DISTINCT jsonb_build_object(
              'object_id', ao.id,
              'object_name', ao.name,
              'type', ao.type
            )
          ) FILTER (WHERE ao.id IS NOT NULL),
          '[]'
        ) AS objects
      FROM Discoverer disc
      LEFT JOIN DiscoveryDiscoverer dd ON dd.discoverer_id = disc.id
      LEFT JOIN Discovery d ON d.id = dd.discovery_id
      LEFT JOIN AstronomicalObject ao ON ao.id = d.object_id
      GROUP BY disc.id
      ORDER BY disc.name ASC
    `);

    res.json(rows);
  } catch (error) {
    console.error("Error fetching discoverers:", error);
    res.status(500).json({ message: "Error fetching discoverers" });
  }
});

app.get("/observatories", async (_req, res) => {
  try {
    const { rows } = await pool.query(`
      SELECT
        obs.id,
        obs.name,
        obs.location,
        obs.country,
        obs.established_year,
        obs.coordinates,
        COUNT(DISTINCT o.id) AS total_observations,
        COUNT(DISTINCT ao.id) AS total_objects
      FROM Observatory obs
      LEFT JOIN Observation o ON o.observatory_id = obs.id
      LEFT JOIN AstronomicalObject ao ON ao.id = o.object_id
      GROUP BY obs.id
      ORDER BY obs.name ASC
    `);

    res.json(rows);
  } catch (error) {
    console.error("Error fetching observatories:", error);
    res.status(500).json({ message: "Error fetching observatories" });
  }
});

app.get("/stats", async (_req, res) => {
  try {
    const { rows } = await pool.query(`
      SELECT
        (SELECT COUNT(*) FROM AstronomicalObject) AS total_objects,
        (SELECT COUNT(*) FROM AstronomicalObject WHERE type = 'Bintang') AS total_stars,
        (SELECT COUNT(*) FROM AstronomicalObject WHERE type = 'Planet') AS total_planets,
        (SELECT COUNT(*) FROM AstronomicalObject WHERE type = 'Galaksi') AS total_galaxies,
        (SELECT COUNT(*) FROM AstronomicalObject WHERE is_habitable = true) AS total_habitable,
        (SELECT COUNT(*) FROM Discoverer) AS total_discoverers,
        (SELECT COUNT(*) FROM Observatory) AS total_observatories
    `);

    res.json(rows[0]);
  } catch (error) {
    console.error("Error fetching stats:", error);
    res.status(500).json({ message: "Error fetching stats" });
  }
});

app.get("/", (_req, res) => {
  res.json({
    message: "Interstellar backend is running",
    endpoints: [
      "GET /objects",
      "GET /objects/:id",
      "GET /discoverers",
      "GET /observatories",
      "GET /stats",
    ],
  });
});

app.use((req, res) => {
  res.status(404).json({ message: "Endpoint not found" });
});

app.listen(port, () => {
  console.log(`Backend running at http://localhost:${port}`);
});
