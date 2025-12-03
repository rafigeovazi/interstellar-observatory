import { useEffect, useMemo, useRef, useState } from "react";
import * as d3 from "d3";
import axios from "axios";
import styles from "@/styles/Home.module.css";

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000";

const asArray = (value) => {
  if (!value) return [];
  if (Array.isArray(value)) return value;
  try {
    const parsed = JSON.parse(value);
    return Array.isArray(parsed) ? parsed : [];
  } catch (error) {
    return [];
  }
};

const formatNumber = (value, options = {}) => {
  if (value === null || value === undefined || Number.isNaN(Number(value))) {
    return "Tidak diketahui";
  }
  return Number(value).toLocaleString("id-ID", options);
};

const formatDistance = (value) => {
  if (value === null || value === undefined) {
    return "Tidak diketahui";
  }
  const formatter = new Intl.NumberFormat("id-ID", {
    notation: "compact",
    maximumFractionDigits: 2,
  });
  return `${formatter.format(value)} LY`;
};

const formatTemperature = (value) => {
  if (value === null || value === undefined) {
    return "Tidak diketahui";
  }
  return `${formatNumber(value, { maximumFractionDigits: 0 })} K`;
};

const formatBoolean = (value) => (value ? "Ya" : "Tidak");

export default function Home() {
  const svgRef = useRef(null);

  const [objects, setObjects] = useState([]);
  const [selectedObjectId, setSelectedObjectId] = useState(null);
  const [selectedObject, setSelectedObject] = useState(null);
  const [brokenPhotoIds, setBrokenPhotoIds] = useState([]);
  const [discoverers, setDiscoverers] = useState([]);
  const [observatories, setObservatories] = useState([]);
  const [stats, setStats] = useState(null);

  const [filterType, setFilterType] = useState("");
  const [filterHabitable, setFilterHabitable] = useState("");
  const [searchTerm, setSearchTerm] = useState("");

  const [loadingObjects, setLoadingObjects] = useState(false);
  const [detailLoading, setDetailLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");

  const fetchObjects = async () => {
    setLoadingObjects(true);
    setErrorMessage("");

    try {
      const params = {};
      if (filterType) params.type = filterType;
      if (filterHabitable) params.habitable = filterHabitable;
      if (searchTerm.trim()) params.search = searchTerm.trim();

      const response = await axios.get(`${API_BASE}/objects`, { params });
      setObjects(response.data);

      if (response.data.length === 0) {
        setSelectedObjectId(null);
        setSelectedObject(null);
      } else {
        const exists = response.data.some(
          (item) => item.id === selectedObjectId
        );
        const nextId = exists ? selectedObjectId : response.data[0].id;
        setSelectedObjectId(nextId);
      }
    } catch (error) {
      console.error("Error fetching objects:", error);
      setErrorMessage("Gagal memuat data objek astronomi.");
    } finally {
      setLoadingObjects(false);
    }
  };

  const fetchObjectDetail = async (id) => {
    if (!id) return;
    setDetailLoading(true);

    try {
      const response = await axios.get(`${API_BASE}/objects/${id}`);
      setSelectedObject(response.data);
    } catch (error) {
      console.error("Error fetching object detail:", error);
      setSelectedObject(null);
    } finally {
      setDetailLoading(false);
    }
  };

  const fetchReferenceData = async () => {
    try {
      const [discoverersRes, observatoriesRes, statsRes] = await Promise.all([
        axios.get(`${API_BASE}/discoverers`),
        axios.get(`${API_BASE}/observatories`),
        axios.get(`${API_BASE}/stats`),
      ]);

      setDiscoverers(discoverersRes.data);
      setObservatories(observatoriesRes.data);
      setStats(statsRes.data);
    } catch (error) {
      console.error("Error fetching reference data:", error);
    }
  };

  useEffect(() => {
    fetchObjects();
    fetchReferenceData();
  }, []);

  useEffect(() => {
    if (selectedObjectId) {
      fetchObjectDetail(selectedObjectId);
      setBrokenPhotoIds([]);
    }
  }, [selectedObjectId]);

  const renderChart = () => {
    if (!svgRef.current) {
      return;
    }

    const svg = d3.select(svgRef.current);
    svg.selectAll("*").remove();

    if (!objects.length) {
      return;
    }

    const chartData = objects.map((item) => {
      const rawDistance = Number(item.distance_light_years);
      const safeDistance =
        Number.isFinite(rawDistance) && rawDistance > 0 ? rawDistance : 0.001;

      const rawMagnitude = Number(item.magnitude);
      const safeMagnitude = Number.isFinite(rawMagnitude) ? rawMagnitude : null;

      return {
        ...item,
        __distance: safeDistance,
        __magnitude: safeMagnitude,
      };
    });

    const width = 900;
    const height = 520;
    const margin = { top: 30, right: 40, bottom: 70, left: 80 };

    svg.attr("viewBox", `0 0 ${width} ${height}`);

    const distances = chartData
      .map((item) => item.__distance)
      .filter((value) => Number.isFinite(value) && value > 0);

    const minDistance = distances.length ? Math.min(...distances) : 0.1;
    const maxDistance = distances.length ? Math.max(...distances) : 10;

    const distancePadding = Math.max((maxDistance - minDistance) * 0.25, 0.5);
    const paddedMin = Math.max(0.001, minDistance - distancePadding);
    const paddedMax = maxDistance + distancePadding;

    const xDomain =
      paddedMin === paddedMax
        ? [paddedMin * 0.8, paddedMax * 1.2]
        : [paddedMin, paddedMax];

    const xScale = d3
      .scaleLog()
      .clamp(true)
      .domain(xDomain)
      .range([margin.left, width - margin.right]);

    const magnitudes = chartData
      .map((item) => item.__magnitude)
      .filter((value) => value !== null && value !== undefined);
    let minMagnitude = Math.min(...magnitudes);
    let maxMagnitude = Math.max(...magnitudes);

    if (!Number.isFinite(minMagnitude)) {
      minMagnitude = -2;
    }
    if (!Number.isFinite(maxMagnitude)) {
      maxMagnitude = 20;
    }

    if (minMagnitude === maxMagnitude) {
      minMagnitude -= 1;
      maxMagnitude += 1;
    }

    const magnitudePadding = (maxMagnitude - minMagnitude) * 0.1 || 1;

    const yScale = d3
      .scaleLinear()
      .domain([
        maxMagnitude + magnitudePadding,
        minMagnitude - magnitudePadding,
      ])
      .range([height - margin.bottom, margin.top]);

    const massDomain = objects.map((item) =>
      item.solar_mass && item.solar_mass > 0 ? item.solar_mass : 0.001
    );
    const minMass = Math.min(...massDomain);
    const maxMass = Math.max(...massDomain);
    const massRange =
      minMass === maxMass
        ? [minMass * 0.8 || 0.0001, maxMass * 1.2 || 0.002]
        : [minMass, maxMass];

    const sizeScale = d3.scaleSqrt().domain(massRange).range([4, 36]);

    const coordinateCount = new Map();
    chartData.forEach((item) => {
      const key = `${item.__distance}|${item.__magnitude ?? "null"}`;
      coordinateCount.set(key, (coordinateCount.get(key) || 0) + 1);
    });
    const coordinateIndex = new Map();

    const colorScale = d3
      .scaleOrdinal()
      .domain(["Bintang", "Planet", "Galaksi"])
      .range(["#64ffda", "#5d9eff", "#f9abff"]);

    const distanceFormatter = new Intl.NumberFormat("id-ID", {
      maximumFractionDigits: 2,
    });

    const xAxis = d3
      .axisBottom(xScale)
      .ticks(6)
      .tickFormat((value) => `${distanceFormatter.format(value)} LY`);

    svg
      .append("g")
      .attr("transform", `translate(0, ${height - margin.bottom})`)
      .attr("color", "#b5c9ff")
      .call(xAxis)
      .append("text")
      .attr("x", (width - margin.left - margin.right) / 2 + margin.left)
      .attr("y", 50)
      .attr("fill", "#b5c9ff")
      .attr("font-size", 16)
      .attr("text-anchor", "middle")
      .text("Jarak (cahaya tahun, skala log)");

    svg
      .append("g")
      .attr("transform", `translate(${margin.left}, 0)`)
      .attr("color", "#b5c9ff")
      .call(d3.axisLeft(yScale))
      .append("text")
      .attr("transform", "rotate(-90)")
      .attr("x", -(height - margin.top - margin.bottom) / 2)
      .attr("y", -50)
      .attr("fill", "#b5c9ff")
      .attr("font-size", 16)
      .attr("text-anchor", "middle")
      .text("Magnitudo (lebih kecil = lebih terang)");

    const tooltipGroup = svg
      .append("g")
      .style("pointer-events", "none")
      .style("display", "none");

    tooltipGroup
      .append("rect")
      .attr("fill", "rgba(7, 16, 45, 0.9)")
      .attr("stroke", "#64ffda")
      .attr("stroke-width", 1)
      .attr("rx", 6)
      .attr("ry", 6)
      .attr("width", 240)
      .attr("height", 82);

    tooltipGroup
      .append("text")
      .attr("fill", "#f8fbff")
      .attr("font-size", 14)
      .attr("x", 12)
      .attr("y", 22)
      .attr("id", "tooltip-line-1");

    tooltipGroup
      .append("text")
      .attr("fill", "#c7d9ff")
      .attr("font-size", 14)
      .attr("x", 12)
      .attr("y", 42)
      .attr("id", "tooltip-line-2");

    tooltipGroup
      .append("text")
      .attr("fill", "#c7d9ff")
      .attr("font-size", 14)
      .attr("x", 12)
      .attr("y", 62)
      .attr("id", "tooltip-line-3");

    svg
      .append("g")
      .selectAll("circle")
      .data(chartData)
      .enter()
      .append("circle")
      .attr("cx", (d) => xScale(d.__distance))
      .attr("cy", (d) => yScale(d.__magnitude ?? maxMagnitude))
      .attr("r", (d) =>
        sizeScale(d.solar_mass && d.solar_mass > 0 ? d.solar_mass : 0.001)
      )
      .attr("fill", (d) => colorScale(d.type))
      .attr("fill-opacity", 0.8)
      .attr("stroke", (d) =>
        d.id === selectedObjectId ? "#ffffff" : "transparent"
      )
      .attr("stroke-width", (d) => (d.id === selectedObjectId ? 2 : 1))
      .attr("transform", (d) => {
        const key = `${d.__distance}|${d.__magnitude ?? "null"}`;
        const total = coordinateCount.get(key) || 1;
        if (total <= 1) {
          return null;
        }
        const index = coordinateIndex.get(key) || 0;
        coordinateIndex.set(key, index + 1);
        const angle = (index / total) * 2 * Math.PI;
        const jitterRadius = 14;
        const offsetX = Math.cos(angle) * jitterRadius;
        const offsetY = Math.sin(angle) * jitterRadius;
        return `translate(${offsetX}, ${offsetY})`;
      })
      .on("mouseover", function (event, datum) {
        d3.select(this).attr("stroke", "#ffffff").attr("stroke-width", 2.2);

        const x = xScale(datum.__distance);
        const y = yScale(datum.__magnitude ?? maxMagnitude);

        tooltipGroup
          .style("display", "block")
          .attr("transform", `translate(${x + 14}, ${y - 80})`);

        tooltipGroup
          .select("#tooltip-line-1")
          .text(`${datum.name} • ${datum.type}`);
        tooltipGroup
          .select("#tooltip-line-2")
          .text(`Jarak: ${formatDistance(datum.distance_light_years)}`);
        tooltipGroup
          .select("#tooltip-line-3")
          .text(`Habitable: ${formatBoolean(datum.is_habitable)}`);
      })
      .on("mouseout", function () {
        d3.select(this)
          .attr("stroke", (d) =>
            d.id === selectedObjectId ? "#ffffff" : "transparent"
          )
          .attr("stroke-width", (d) => (d.id === selectedObjectId ? 2 : 1));
        tooltipGroup.style("display", "none");
      })
      .on("click", (_, datum) => {
        setSelectedObjectId(datum.id);
      });
  };

  useEffect(() => {
    renderChart();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [objects, selectedObjectId]);

  const handleApplyFilters = (event) => {
    event.preventDefault();
    fetchObjects();
  };

  const handleResetFilters = () => {
    setFilterType("");
    setFilterHabitable("");
    setSearchTerm("");
    fetchObjects();
  };

  const summaryDiscoverers = useMemo(() => {
    if (!selectedObject) {
      return [];
    }
    return asArray(selectedObject.discoverers);
  }, [selectedObject]);

  const photosToRender = useMemo(() => {
    if (!selectedObject || !Array.isArray(selectedObject.photos)) {
      return [];
    }

    const sanitized = selectedObject.photos.map((photo, index) => {
      const normalizedUrl =
        typeof photo?.url === "string" ? photo.url.trim() : "";
      const normalizedCaption =
        typeof photo?.caption === "string" ? photo.caption.trim() : "";

      return {
        ...photo,
        url: normalizedUrl,
        caption: normalizedCaption,
        __renderId: photo?.id ?? `local-${index}`,
        __captionKey: normalizedCaption.toLowerCase(),
      };
    });

    const photosWithImage = [];
    const seenImageSignature = new Set();

    sanitized.forEach((photo) => {
      if (!photo.url || brokenPhotoIds.includes(photo.__renderId)) {
        return;
      }

      const signature = `${photo.url}|${photo.__captionKey}`;
      if (seenImageSignature.has(signature)) {
        return;
      }
      seenImageSignature.add(signature);
      photosWithImage.push(photo);
    });

    if (photosWithImage.length === 0) {
      return [];
    }

    const primaryCandidate =
      photosWithImage.find((photo) => photo.is_primary && photo.url) ||
      photosWithImage[0];

    return photosWithImage.map((photo) => ({
      ...photo,
      displayPrimary: primaryCandidate
        ? photo.__renderId === primaryCandidate.__renderId
        : false,
    }));
  }, [selectedObject, brokenPhotoIds]);

  const primaryPhoto = useMemo(() => {
    if (photosToRender.length === 0) {
      return null;
    }
    return photosToRender.find((photo) => photo.displayPrimary) || null;
  }, [photosToRender]);

  return (
    <div className={styles.container}>
      <header className={styles.header}>
        <div>
          <h1 className={styles.title}>Interstellar Observatory</h1>
          <p className={styles.subtitle}>
            Created by: Prof. Rafi Geovazi, PhD, ACM Fellow.
          </p>
        </div>
        {stats && (
          <div className={styles.stats}>
            <div className={styles.statCard}>
              <span>Total Objek</span>
              <strong>{formatNumber(stats.total_objects)}</strong>
            </div>
            <div className={styles.statCard}>
              <span>Bintang</span>
              <strong>{formatNumber(stats.total_stars)}</strong>
            </div>
            <div className={styles.statCard}>
              <span>Planet</span>
              <strong>{formatNumber(stats.total_planets)}</strong>
            </div>
            <div className={styles.statCard}>
              <span>Galaksi</span>
              <strong>{formatNumber(stats.total_galaxies)}</strong>
            </div>
            <div className={styles.statCard}>
              <span>Layak Huni</span>
              <strong>{formatNumber(stats.total_habitable)}</strong>
            </div>
            <div className={styles.statCard}>
              <span>Penemu</span>
              <strong>{formatNumber(stats.total_discoverers)}</strong>
            </div>
            <div className={styles.statCard}>
              <span>Observatorium</span>
              <strong>{formatNumber(stats.total_observatories)}</strong>
            </div>
          </div>
        )}
      </header>

      <form className={styles.filters} onSubmit={handleApplyFilters}>
        <div className={styles.filterGroup}>
          <label htmlFor="type">Tipe Objek</label>
          <select
            id="type"
            value={filterType}
            onChange={(event) => setFilterType(event.target.value)}
          >
            <option value="">Semua</option>
            <option value="Bintang">Bintang</option>
            <option value="Planet">Planet</option>
            <option value="Galaksi">Galaksi</option>
          </select>
        </div>

        <div className={styles.filterGroup}>
          <label htmlFor="habitable">Layak Huni</label>
          <select
            id="habitable"
            value={filterHabitable}
            onChange={(event) => setFilterHabitable(event.target.value)}
          >
            <option value="">Semua</option>
            <option value="true">Ya</option>
            <option value="false">Tidak</option>
          </select>
        </div>

        <div className={styles.filterGroup}>
          <label htmlFor="search">Cari Nama Objek</label>
          <input
            id="search"
            type="search"
            placeholder="Contoh: Planet Geonazi"
            value={searchTerm}
            onChange={(event) => setSearchTerm(event.target.value)}
          />
        </div>

        <div className={styles.filterActions}>
          <button type="submit">Cari</button>
          <button type="button" onClick={handleResetFilters}>
            Reset
          </button>
        </div>
      </form>

      {errorMessage && <p className={styles.error}>{errorMessage}</p>}

      <div className={styles.mainContent}>
        <div className={styles.chartSection}>
          <div className={styles.chartHeader}>
            <h2>Diagram Magnitudo vs Jarak</h2>
            <p>
              Ukuran lingkaran mewakili massa relatif (massa matahari). Klik
              titik untuk melihat detail lengkap.
            </p>
          </div>
          <svg ref={svgRef} className={styles.chart} />
        </div>

        <aside className={styles.listSection}>
          <h2>Daftar Objek Astronomi</h2>
          {loadingObjects ? (
            <div className={styles.loading}>Memuat objek...</div>
          ) : objects.length === 0 ? (
            <p className={styles.emptyState}>
              Tidak ada data untuk filter yang dipilih.
            </p>
          ) : (
            <div className={styles.objectList}>
              {objects.map((item) => {
                const discovererNames = asArray(item.discoverers)
                  .map((discoverer) => discoverer.name)
                  .filter(Boolean);
                const discovererLabel =
                  discovererNames.length > 0
                    ? discovererNames.slice(0, 2).join(", ") +
                      (discovererNames.length > 2
                        ? ` +${discovererNames.length - 2}`
                        : "")
                    : "Tidak diketahui";

                return (
                  <button
                    key={item.id}
                    type="button"
                    className={`${styles.objectCard} ${
                      item.id === selectedObjectId
                        ? styles.objectCardActive
                        : ""
                    }`}
                    onClick={() => setSelectedObjectId(item.id)}
                  >
                    <div className={styles.objectCardHeader}>
                      <h3>{item.name}</h3>
                      <span
                        className={`${styles.badge} ${
                          styles[`badge${item.type}`] || ""
                        }`}
                      >
                        {item.type}
                      </span>
                    </div>
                    <div className={styles.objectCardBody}>
                      <p>
                        <strong>Magnitudo:</strong>{" "}
                        {formatNumber(item.magnitude, {
                          maximumFractionDigits: 2,
                        })}
                      </p>
                      <p>
                        <strong>Jarak:</strong>{" "}
                        {formatDistance(item.distance_light_years)}
                      </p>
                      <p>
                        <strong>Layak Huni:</strong>{" "}
                        {formatBoolean(item.is_habitable)}
                      </p>
                      <p>
                        <strong>Penemu:</strong> {discovererLabel}
                      </p>
                    </div>
                  </button>
                );
              })}
            </div>
          )}
        </aside>
      </div>

      <section className={styles.detailsSection}>
        <h2>Detail Objek</h2>
        {detailLoading ? (
          <div className={styles.loading}>Memuat detail objek...</div>
        ) : !selectedObject ? (
          <p className={styles.emptyState}>
            Pilih objek dari daftar atau grafik untuk melihat detail.
          </p>
        ) : (
          <div className={styles.detailContent}>
            <div className={styles.detailHeader}>
              <div>
                <h3>{selectedObject.name}</h3>
                <p>
                  {selectedObject.type} • Magnitudo{" "}
                  {formatNumber(selectedObject.magnitude, {
                    maximumFractionDigits: 2,
                  })}
                </p>
              </div>
              <div
                className={`${styles.badge} ${
                  styles[`badge${selectedObject.type}`] || ""
                }`}
              >
                {selectedObject.is_habitable
                  ? "Layak Huni"
                  : selectedObject.type}
              </div>
            </div>

            <div className={styles.detailGrid}>
              <div>
                <span>Jarak: </span>
                <strong>
                  {formatDistance(selectedObject.distance_light_years)}
                </strong>
              </div>
              <div>
                <span>Suhu: </span>
                <strong>
                  {formatTemperature(selectedObject.temperature_kelvin)}
                </strong>
              </div>
              <div>
                <span>Massa (matahari): </span>
                <strong>
                  {formatNumber(selectedObject.solar_mass, {
                    maximumFractionDigits: 2,
                  })}
                </strong>
              </div>
              <div>
                <span>Tanggal Dibuat: </span>
                <strong>
                  {selectedObject.created_at
                    ? new Date(selectedObject.created_at).toLocaleDateString(
                        "id-ID"
                      )
                    : "Tidak diketahui"}
                </strong>
              </div>
              <div>
                <span>Layak Huni: </span>
                <strong>{formatBoolean(selectedObject.is_habitable)}</strong>
              </div>
              <div>
                <span>Kelas Spektral: </span>
                <strong>
                  {selectedObject.spectral_class || "Tidak diketahui"}
                </strong>
              </div>
              <div>
                <span>Luminositas: </span>
                <strong>
                  {formatNumber(selectedObject.luminosity, {
                    maximumFractionDigits: 2,
                  })}
                </strong>
              </div>
              <div>
                <span>Radius (matahari): </span>
                <strong>
                  {formatNumber(selectedObject.radius_solar, {
                    maximumFractionDigits: 2,
                  })}
                </strong>
              </div>
            </div>

            {summaryDiscoverers.length > 0 && (
              <div className={styles.detailCard}>
                <h4>Ringkasan Penemu: </h4>
                <ul>
                  {summaryDiscoverers.map((discoverer) => (
                    <li key={discoverer.name}>
                      <strong>{discoverer.name}</strong>
                      {discoverer.nationality
                        ? ` • ${discoverer.nationality}`
                        : ""}
                      {discoverer.birth_year
                        ? ` • ${discoverer.birth_year}`
                        : ""}
                    </li>
                  ))}
                </ul>
              </div>
            )}

            <div className={styles.secondaryGrid}>
              <div className={styles.detailCard}>
                <h4>Catatan Penemuan: </h4>
                {selectedObject.discoveries &&
                selectedObject.discoveries.length > 0 ? (
                  <ul>
                    {selectedObject.discoveries.map((discovery) => {
                      const localDiscoverers = asArray(discovery.discoverers);
                      return (
                        <li key={discovery.id}>
                          <strong>
                            {discovery.discovery_date
                              ? new Date(
                                  discovery.discovery_date
                                ).toLocaleDateString("id-ID")
                              : "Tanggal tidak diketahui"}
                          </strong>
                          <div>
                            Metode:{" "}
                            {discovery.discovery_method || "Tidak diketahui"}
                          </div>
                          {localDiscoverers.length > 0 && (
                            <div>
                              Penemu:{" "}
                              {localDiscoverers
                                .map((item) => item.name)
                                .join(", ")}
                            </div>
                          )}
                          {discovery.notes && (
                            <div>Catatan: {discovery.notes}</div>
                          )}
                        </li>
                      );
                    })}
                  </ul>
                ) : (
                  <p>Tidak ada data penemuan.</p>
                )}
              </div>

              <div className={styles.detailCard}>
                <h4>Observasi</h4>
                {selectedObject.observations &&
                selectedObject.observations.length > 0 ? (
                  <ul>
                    {selectedObject.observations.map((observation) => (
                      <li key={observation.id}>
                        <strong>{observation.observatory_name}</strong>
                        <div>
                          {observation.observation_date
                            ? new Date(
                                observation.observation_date
                              ).toLocaleString("id-ID")
                            : "Tanggal tidak tersedia"}
                        </div>
                        <div>
                          Instrumen:{" "}
                          {observation.instrument || "Tidak diketahui"}
                        </div>
                        {observation.wavelength && (
                          <div>Panjang gelombang: {observation.wavelength}</div>
                        )}
                        {observation.notes && (
                          <div>Catatan: {observation.notes}</div>
                        )}
                      </li>
                    ))}
                  </ul>
                ) : (
                  <p>Belum ada catatan observasi.</p>
                )}
              </div>
            </div>

            <div className={styles.detailCard}>
              <h4>Galeri Foto</h4>
              {photosToRender.length > 0 ? (
                <div className={styles.photoGrid}>
                  {photosToRender.map((photo) => (
                    <figure
                      key={photo.__renderId}
                      data-has-image={
                        photo?.url && photo.url.trim() ? "true" : "false"
                      }
                      className={
                        photo.displayPrimary ? styles.primaryPhoto : ""
                      }
                    >
                      <img
                        src={photo.url.trim()}
                        alt={photo.caption || selectedObject.name}
                        loading="lazy"
                        onError={(event) => {
                          if (event.currentTarget.dataset.broken !== "true") {
                            event.currentTarget.dataset.broken = "true";
                            event.currentTarget.src = "";
                            setBrokenPhotoIds((prev) =>
                              prev.includes(photo.__renderId)
                                ? prev
                                : [...prev, photo.__renderId]
                            );
                          }
                        }}
                      />
                      <figcaption>
                        <strong>{photo.caption || "Tanpa judul"}</strong>
                        <span>
                          {photo.taken_date
                            ? new Date(photo.taken_date).toLocaleDateString(
                                "id-ID"
                              )
                            : "Tanggal tidak diketahui"}
                        </span>
                        {photo.telescope && (
                          <span>Teleskop: {photo.telescope}</span>
                        )}
                        {photo.instrument && (
                          <span>Instrumen: {photo.instrument}</span>
                        )}
                        {photo.wavelength_filter && (
                          <span>Filter: {photo.wavelength_filter}</span>
                        )}
                      </figcaption>
                    </figure>
                  ))}
                </div>
              ) : (
                <p>Belum ada foto terdaftar.</p>
              )}
              {primaryPhoto && (
                <p className={styles.primaryPhotoNote}>
                  Foto utama:{" "}
                  {primaryPhoto.caption ||
                    (primaryPhoto.url && primaryPhoto.url.trim()
                      ? primaryPhoto.url.trim()
                      : "Gambar tidak tersedia")}
                </p>
              )}
            </div>
          </div>
        )}
      </section>

      <section className={styles.referenceSection}>
        <div className={styles.referenceCard}>
          <h2>Daftar Penemu</h2>
          {discoverers.length === 0 ? (
            <p className={styles.emptyState}>Belum ada data penemu.</p>
          ) : (
            <table className={styles.table}>
              <thead>
                <tr>
                  <th>Nama</th>
                  <th>Kebangsaan</th>
                  <th>Lahir</th>
                  <th>Total Penemuan</th>
                </tr>
              </thead>
              <tbody>
                {discoverers.map((discoverer) => (
                  <tr key={discoverer.id}>
                    <td>
                      <strong>{discoverer.name}</strong>
                      <div className={styles.tableNote}>{discoverer.bio}</div>
                    </td>
                    <td>{discoverer.nationality || "-"}</td>
                    <td>{discoverer.birth_year || "-"}</td>
                    <td>{formatNumber(discoverer.total_discoveries)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>

        <div className={styles.referenceCard}>
          <h2>Observatorium</h2>
          {observatories.length === 0 ? (
            <p className={styles.emptyState}>Belum ada data observatorium.</p>
          ) : (
            <table className={styles.table}>
              <thead>
                <tr>
                  <th>Observatorium</th>
                  <th>Lokasi</th>
                  <th>Negara</th>
                  <th>Didirikan</th>
                  <th>Observasi</th>
                  <th>Objek</th>
                </tr>
              </thead>
              <tbody>
                {observatories.map((observatory) => (
                  <tr key={observatory.id}>
                    <td>{observatory.name}</td>
                    <td>{observatory.location || "-"}</td>
                    <td>{observatory.country || "-"}</td>
                    <td>{observatory.established_year || "-"}</td>
                    <td>{formatNumber(observatory.total_observations)}</td>
                    <td>{formatNumber(observatory.total_objects)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </section>
    </div>
  );
}
