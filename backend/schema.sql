-- Table: Discoverer
CREATE TABLE Discoverer (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    nationality VARCHAR(50),
    birth_year INTEGER,
    bio TEXT
);

-- Table: Observatory
CREATE TABLE Observatory (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    location VARCHAR(100),
    country VARCHAR(50),
    established_year INTEGER,
    coordinates VARCHAR(50)
);

-- Table: AstronomicalObject
CREATE TABLE AstronomicalObject (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('Bintang', 'Planet', 'Galaksi')),
    magnitude FLOAT,
    temperature_kelvin FLOAT,
    distance_light_years FLOAT,
    solar_mass FLOAT,
    is_habitable BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: StarDetails (for star-specific attributes)
CREATE TABLE StarDetails (
    object_id INTEGER PRIMARY KEY REFERENCES AstronomicalObject(id) ON DELETE CASCADE,
    spectral_class VARCHAR(10),
    luminosity FLOAT,
    radius_solar FLOAT
);

-- Table: Discovery
CREATE TABLE Discovery (
    id SERIAL PRIMARY KEY,
    object_id INTEGER REFERENCES AstronomicalObject(id) ON DELETE CASCADE,
    discovery_date DATE,
    discovery_method VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: DiscoveryDiscoverer (junction table for many-to-many relationship)
CREATE TABLE DiscoveryDiscoverer (
    discovery_id INTEGER REFERENCES Discovery(id) ON DELETE CASCADE,
    discoverer_id INTEGER REFERENCES Discoverer(id) ON DELETE CASCADE,
    PRIMARY KEY (discovery_id, discoverer_id)
);

-- Table: Observation
CREATE TABLE Observation (
    id SERIAL PRIMARY KEY,
    object_id INTEGER REFERENCES AstronomicalObject(id) ON DELETE CASCADE,
    observatory_id INTEGER REFERENCES Observatory(id),
    observation_date TIMESTAMP,
    instrument VARCHAR(100),
    wavelength VARCHAR(20),
    exposure_time VARCHAR(20),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: Photo
CREATE TABLE Photo (
    id SERIAL PRIMARY KEY,
    object_id INTEGER REFERENCES AstronomicalObject(id) ON DELETE CASCADE,
    url VARCHAR(500) NOT NULL,
    caption TEXT,
    taken_date DATE,
    telescope VARCHAR(100),
    instrument VARCHAR(100),
    wavelength_filter VARCHAR(20),
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert data into Discoverer table
INSERT INTO Discoverer (name, nationality, birth_year, bio) VALUES
('Edmond Halley', 'English', 1656, 'English astronomer, geophysicist, mathematician, meteorologist, and physicist'),
('William Herschel', 'German-British', 1738, 'Discovered Uranus and infrared radiation'),
('Johannes Kepler', 'German', 1571, 'German astronomer who discovered the laws of planetary motion'),
('Galileo Galilei', 'Italian', 1564, 'Italian astronomer who improved the telescope'),
('Pierre-Simon Laplace', 'French', 1749, 'French mathematician and astronomer'),
('NASA Kepler Team', 'American', NULL, 'NASA team that discovered numerous exoplanets'),
('TRAPPIST Team', 'International', NULL, 'Team that discovered the TRAPPIST-1 system'),
('K2 Mission Team', 'American', NULL, 'NASA K2 mission team'),
('TESS Team', 'American', NULL, 'NASA Transiting Exoplanet Survey Satellite team'),
('Hubble Space Telescope Team', 'International', NULL, 'Hubble Space Telescope operations team'),
('European Southern Observatory', 'International', NULL, 'ESO observatory team'),
('Cerro Tololo Observatory', 'Chilean', NULL, 'Chilean observatory team'),
('Mauna Kea Observatory', 'American', NULL, 'Hawaiian observatory team'),
('Sloan Digital Sky Survey', 'American', NULL, 'SDSS survey team'),
('Chandra X-ray Observatory', 'American', NULL, 'NASA X-ray observatory team');

-- Insert data into Observatory table
INSERT INTO Observatory (name, location, country, established_year, coordinates) VALUES
('Hubble Space Telescope', 'Earth Orbit', 'International', 1990, 'Orbital'),
('Kepler Space Telescope', 'Earth Orbit', 'USA', 2009, 'Orbital'),
('TRAPPIST', 'La Silla Observatory', 'Chile', 2010, '29°15′S 70°44′W'),
('ESO Very Large Telescope', 'Paranal Observatory', 'Chile', 1998, '24°37′S 70°24′W'),
('Mauna Kea Observatory', 'Mauna Kea', 'USA', 1967, '19°49′N 155°28′W'),
('Cerro Tololo Observatory', 'Cerro Tololo', 'Chile', 1965, '30°10′S 70°48′W'),
('Palomar Observatory', 'Palomar Mountain', 'USA', 1948, '33°21′N 116°51′W'),
('Kitt Peak National Observatory', 'Kitt Peak', 'USA', 1958, '31°57′N 111°36′W'),
('La Silla Observatory', 'La Silla', 'Chile', 1966, '29°15′S 70°44′W'),
('Arecibo Observatory', 'Arecibo', 'Puerto Rico', 1963, '18°20′N 66°45′W'),
('Green Bank Observatory', 'Green Bank', 'USA', 1957, '38°25′N 79°50′W'),
('Siding Spring Observatory', 'Coonabarabran', 'Australia', 1964, '31°16′S 149°04′E'),
('Mount Stromlo Observatory', 'Canberra', 'Australia', 1924, '35°19′S 149°01′E'),
('Anglo-Australian Telescope', 'Coonabarabran', 'Australia', 1974, '31°16′S 149°04′E'),
('Subaru Telescope', 'Mauna Kea', 'Japan', 1999, '19°49′N 155°28′W');

-- Insert all astronomical objects from the Excel data
INSERT INTO AstronomicalObject (name, type, magnitude, temperature_kelvin, distance_light_years, solar_mass, is_habitable) VALUES
('Sirius', 'Bintang', -1.46, 9940, 8.6, 2.1, false),
('Proxima Centauri', 'Bintang', 11.13, 3042, 4.2, 0.12, true),
('Betelgeuse', 'Bintang', 0.5, 3590, 643, 11.6, false),
('Vega', 'Bintang', 0.03, 9602, 25.04, 2.1, false),
('Rigel', 'Bintang', 0.13, 11000, 863, 18, false),
('Kepler-452b', 'Planet', 13.4, 279, 1402, 0, true),
('HD 209458b', 'Planet', 12, 1359, 159, 0.69, false),
('Gliese 581g', 'Planet', 15.8, 228, 20.4, 0, true),
('WASP-12b', 'Planet', 11.7, 2516, 871, 1.41, false),
('Andromeda', 'Galaksi', 3.4, 4000, 2537000, 1000000, false),
('Capella', 'Bintang', 0.08, 4970, 42.9, 2.6, false),
('Arcturus', 'Bintang', -0.05, 4286, 36.7, 1.1, false),
('Aldebaran', 'Bintang', 0.85, 3910, 65.3, 1.5, false),
('Spica', 'Bintang', 1.04, 22400, 262, 10.25, false),
('Antares', 'Bintang', 1.09, 3660, 604, 12, false),
('Pollux', 'Bintang', 1.14, 4666, 33.78, 1.9, false),
('Fomalhaut', 'Bintang', 1.16, 8590, 25.13, 1.9, false),
('Deneb', 'Bintang', 1.25, 8525, 2615, 19, false),
('Regulus', 'Bintang', 1.35, 12460, 79.3, 3.8, false),
('Canopus', 'Bintang', -0.74, 7350, 310, 8, false),
('Kepler-186f', 'Planet', 14.2, 188, 561, 0, true),
('TRAPPIST-1e', 'Planet', 18.8, 251, 39.6, 0, true),
('K2-18b', 'Planet', 13.3, 265, 124, 2.3, true),
('TOI-715b', 'Planet', 15.1, 289, 137, 1.55, true),
('55 Cancri e', 'Planet', 8.2, 2573, 40.3, 0.026, false),
('CoRoT-7b', 'Planet', 11.7, 1800, 489, 0.015, false),
('Kepler-16b', 'Planet', 12, 200, 245, 0.33, false),
('HAT-P-7b', 'Planet', 10.4, 2730, 1044, 1.8, false),
('XO-3b', 'Planet', 9.8, 1993, 850, 11.79, false),
('WASP-33b', 'Planet', 8.3, 3398, 378, 2.1, false),
('Milky Way', 'Galaksi', 0, 2700, 0, 100000, true),
('Large Magellanic Cloud', 'Galaksi', 0.9, 3000, 160000, 10000, false),
('Small Magellanic Cloud', 'Galaksi', 2.7, 3000, 200000, 7000, false),
('Triangulum', 'Galaksi', 5.72, 3500, 3000000, 50000, false),
('Whirlpool', 'Galaksi', 8.4, 4000, 23000000, 160000, false),
('Sombrero', 'Galaksi', 8, 4200, 29000000, 800000, false),
('Centaurus A', 'Galaksi', 6.84, 4500, 13000000, 1000000, false),
('Pinwheel', 'Galaksi', 7.86, 3800, 21000000, 100000, false),
('Messier 87', 'Galaksi', 8.6, 4800, 53000000, 6400000, false),
('NGC 1300', 'Galaksi', 10.4, 4100, 61000000, 200000, false),
('Alpha Centauri A', 'Bintang', 0.01, 5790, 4.37, 1.1, true),
('Alpha Centauri B', 'Bintang', 1.33, 5260, 4.37, 0.9, true),
('Barnard''s Star', 'Bintang', 9.53, 3134, 5.96, 0.14, true),
('Wolf 359', 'Bintang', 13.44, 2800, 7.86, 0.09, true),
('Lalande 21185', 'Bintang', 7.47, 3828, 8.29, 0.39, true),
('Luyten 726-8A', 'Bintang', 12.54, 2670, 8.73, 0.1, true),
('Epsilon Eridani', 'Bintang', 3.73, 5084, 10.52, 0.82, true),
('Procyon A', 'Bintang', 0.38, 6530, 11.46, 1.5, false),
('61 Cygni A', 'Bintang', 5.21, 4374, 11.4, 0.7, true),
('Tau Ceti', 'Bintang', 3.49, 5344, 11.9, 0.78, true),
('40 Eridani A', 'Bintang', 4.43, 5300, 16.3, 0.84, true),
('HD 164595', 'Bintang', 7, 5790, 94.4, 0.99, true),
('Kepler-442b', 'Planet', 13.7, 233, 1206, 0, true),
('Kepler-438b', 'Planet', 14.76, 276, 473, 0, true),
('HD 40307g', 'Planet', 7.17, 269, 42, 0, true),
('Gliese 667Cc', 'Planet', 10.25, 277, 23.62, 0, true),
('Kepler-22b', 'Planet', 11.5, 262, 638, 0, true),
('WASP-121b', 'Planet', 10.4, 2358, 881, 1.18, false),
('Kepler-10b', 'Planet', 11.2, 1833, 564, 0.014, false),
('GJ 1214b', 'Planet', 14.7, 393, 47, 0.02, false),
('Kepler-7b', 'Planet', 13, 1540, 3000, 0.43, false),
('TrES-2b', 'Planet', 11.4, 1435, 718, 1.25, false),
('OGLE-TR-56b', 'Planet', 16.6, 1870, 4900, 1.29, false),
('WASP-43b', 'Planet', 12.4, 1398, 261, 2.03, false),
('HAT-P-1b', 'Planet', 10.4, 1322, 526, 0.53, false),
('XO-1b', 'Planet', 11.3, 1201, 560, 0.9, false),
('TrES-1b', 'Planet', 11.8, 1070, 512, 0.75, false),
('WASP-17b', 'Planet', 11.6, 1740, 1020, 0.49, false),
('CoRoT-1b', 'Planet', 13.6, 1898, 1560, 1.03, false);

-- Insert star details for all stars
INSERT INTO StarDetails (object_id, spectral_class, luminosity, radius_solar)
SELECT 
    ao.id,
    CASE 
        WHEN ao.name = 'Sirius' THEN 'A'
        WHEN ao.name = 'Proxima Centauri' THEN 'M'
        WHEN ao.name = 'Betelgeuse' THEN 'M'
        WHEN ao.name = 'Vega' THEN 'A'
        WHEN ao.name = 'Rigel' THEN 'B'
        WHEN ao.name = 'Capella' THEN 'G'
        WHEN ao.name = 'Arcturus' THEN 'K'
        WHEN ao.name = 'Aldebaran' THEN 'K'
        WHEN ao.name = 'Spica' THEN 'B'
        WHEN ao.name = 'Antares' THEN 'M'
        WHEN ao.name = 'Pollux' THEN 'K'
        WHEN ao.name = 'Fomalhaut' THEN 'A'
        WHEN ao.name = 'Deneb' THEN 'A'
        WHEN ao.name = 'Regulus' THEN 'B'
        WHEN ao.name = 'Canopus' THEN 'A'
        WHEN ao.name = 'Alpha Centauri A' THEN 'G'
        WHEN ao.name = 'Alpha Centauri B' THEN 'K'
        WHEN ao.name = 'Barnard''s Star' THEN 'M'
        WHEN ao.name = 'Wolf 359' THEN 'M'
        WHEN ao.name = 'Lalande 21185' THEN 'M'
        WHEN ao.name = 'Luyten 726-8A' THEN 'M'
        WHEN ao.name = 'Epsilon Eridani' THEN 'K'
        WHEN ao.name = 'Procyon A' THEN 'F'
        WHEN ao.name = '61 Cygni A' THEN 'K'
        WHEN ao.name = 'Tau Ceti' THEN 'G'
        WHEN ao.name = '40 Eridani A' THEN 'K'
        WHEN ao.name = 'HD 164595' THEN 'G'
        ELSE NULL
    END AS spectral_class,
    CASE 
        WHEN ao.name = 'Sirius' THEN 25.4
        WHEN ao.name = 'Proxima Centauri' THEN 0.0017
        WHEN ao.name = 'Betelgeuse' THEN 90000
        WHEN ao.name = 'Vega' THEN 40
        WHEN ao.name = 'Rigel' THEN 40000
        WHEN ao.name = 'Capella' THEN 78
        WHEN ao.name = 'Arcturus' THEN 170
        WHEN ao.name = 'Aldebaran' THEN 440
        WHEN ao.name = 'Spica' THEN 12000
        WHEN ao.name = 'Antares' THEN 65000
        WHEN ao.name = 'Pollux' THEN 32
        WHEN ao.name = 'Fomalhaut' THEN 16
        WHEN ao.name = 'Deneb' THEN 196000
        WHEN ao.name = 'Regulus' THEN 288
        WHEN ao.name = 'Canopus' THEN 10700
        WHEN ao.name = 'Alpha Centauri A' THEN 1.5
        WHEN ao.name = 'Alpha Centauri B' THEN 0.5
        WHEN ao.name = 'Barnard''s Star' THEN 0.0035
        WHEN ao.name = 'Wolf 359' THEN 0.001
        WHEN ao.name = 'Lalande 21185' THEN 0.025
        WHEN ao.name = 'Luyten 726-8A' THEN 0.0016
        WHEN ao.name = 'Epsilon Eridani' THEN 0.37
        WHEN ao.name = 'Procyon A' THEN 6.9
        WHEN ao.name = '61 Cygni A' THEN 0.15
        WHEN ao.name = 'Tau Ceti' THEN 0.52
        WHEN ao.name = '40 Eridani A' THEN 0.46
        WHEN ao.name = 'HD 164595' THEN 1.0
        ELSE NULL
    END AS luminosity,
    CASE 
        WHEN ao.name = 'Sirius' THEN 1.711
        WHEN ao.name = 'Proxima Centauri' THEN 0.1542
        WHEN ao.name = 'Betelgeuse' THEN 887
        WHEN ao.name = 'Vega' THEN 2.362
        WHEN ao.name = 'Rigel' THEN 78.9
        WHEN ao.name = 'Capella' THEN 11.98
        WHEN ao.name = 'Arcturus' THEN 25.4
        WHEN ao.name = 'Aldebaran' THEN 44.13
        WHEN ao.name = 'Spica' THEN 7.4
        WHEN ao.name = 'Antares' THEN 680
        WHEN ao.name = 'Pollux' THEN 8.8
        WHEN ao.name = 'Fomalhaut' THEN 1.842
        WHEN ao.name = 'Deneb' THEN 203
        WHEN ao.name = 'Regulus' THEN 3.14
        WHEN ao.name = 'Canopus' THEN 71
        WHEN ao.name = 'Alpha Centauri A' THEN 1.227
        WHEN ao.name = 'Alpha Centauri B' THEN 0.865
        WHEN ao.name = 'Barnard''s Star' THEN 0.196
        WHEN ao.name = 'Wolf 359' THEN 0.16
        WHEN ao.name = 'Lalande 21185' THEN 0.392
        WHEN ao.name = 'Luyten 726-8A' THEN 0.127
        WHEN ao.name = 'Epsilon Eridani' THEN 0.735
        WHEN ao.name = 'Procyon A' THEN 2.048
        WHEN ao.name = '61 Cygni A' THEN 0.665
        WHEN ao.name = 'Tau Ceti' THEN 0.793
        WHEN ao.name = '40 Eridani A' THEN 0.813
        WHEN ao.name = 'HD 164595' THEN 1.02
        ELSE NULL
    END AS radius_solar
FROM AstronomicalObject ao
WHERE ao.type = 'Bintang';

-- Insert discovery records for all objects
INSERT INTO Discovery (object_id, discovery_date, discovery_method, notes)
SELECT 
    ao.id,
    CASE 
        -- Untuk objek kuno: gunakan NULL (bukan teks)
        WHEN ao.name IN ('Sirius', 'Proxima Centauri', 'Betelgeuse', 'Vega', 'Rigel', 'Capella', 'Arcturus', 'Aldebaran', 'Spica', 'Antares', 'Pollux', 'Fomalhaut', 'Deneb', 'Regulus', 'Canopus', 'Alpha Centauri A', 'Alpha Centauri B', 'Barnard''s Star', 'Wolf 359', 'Lalande 21185', 'Luyten 726-8A', 'Epsilon Eridani', 'Procyon A', '61 Cygni A', 'Tau Ceti', '40 Eridani A', 'HD 164595', 'Andromeda', 'Milky Way') 
            THEN NULL
            
        -- Untuk objek historis: GUNAKAN FORMAT TANGGAL LENGKAP 'YYYY-MM-DD'
        WHEN ao.name IN ('Large Magellanic Cloud', 'Small Magellanic Cloud') THEN '1519-01-01'::DATE
        WHEN ao.name = 'Triangulum' THEN '1654-01-01'::DATE
        WHEN ao.name = 'Whirlpool' THEN '1779-01-01'::DATE
        WHEN ao.name IN ('Sombrero', 'Pinwheel', 'Messier 87') THEN '1781-01-01'::DATE
        WHEN ao.name = 'Centaurus A' THEN '1826-01-01'::DATE
        WHEN ao.name = 'NGC 1300' THEN '1885-01-01'::DATE
        
        -- Untuk objek modern: tetap gunakan format DATE
        WHEN ao.name LIKE 'Kepler-%' THEN '2015-07-23'::DATE
        WHEN ao.name LIKE 'WASP-%' THEN '2011-04-01'::DATE
        WHEN ao.name LIKE 'HD %' THEN '2005-01-01'::DATE
        WHEN ao.name LIKE 'Gliese %' THEN '2010-09-29'::DATE
        WHEN ao.name LIKE 'TRAPPIST-%' THEN '2017-02-22'::DATE
        WHEN ao.name LIKE 'K2-%' THEN '2019-01-08'::DATE
        WHEN ao.name LIKE 'TOI-%' THEN '2023-01-01'::DATE
        WHEN ao.name LIKE 'CoRoT-%' THEN '2009-02-03'::DATE
        WHEN ao.name LIKE 'HAT-P-%' THEN '2008-09-02'::DATE
        WHEN ao.name LIKE 'XO-%' THEN '2007-05-01'::DATE
        WHEN ao.name LIKE 'TrES-%' THEN '2006-03-21'::DATE
        WHEN ao.name LIKE 'OGLE-%' THEN '2002-11-23'::DATE
        WHEN ao.name LIKE 'GJ %' THEN '2009-12-16'::DATE
        
        -- Default
        ELSE '2000-01-01'::DATE
    END AS discovery_date,
    
    -- Discovery method juga perlu disesuaikan (harus konsisten dengan perubahan di atas)
    CASE 
        WHEN ao.type = 'Planet' THEN 'Transit Method'
        WHEN ao.type = 'Bintang' AND ao.name IN ('Sirius', 'Proxima Centauri', 'Betelgeuse', 'Vega', 'Rigel', 'Capella', 'Arcturus', 'Aldebaran', 'Spica', 'Antares', 'Pollux', 'Fomalhaut', 'Deneb', 'Regulus', 'Canopus', 'Alpha Centauri A', 'Alpha Centauri B', 'Barnard''s Star', 'Wolf 359', 'Lalande 21185', 'Luyten 726-8A', 'Epsilon Eridani', 'Procyon A', '61 Cygni A', 'Tau Ceti', '40 Eridani A', 'HD 164595') THEN 'Visual Observation'
        WHEN ao.type = 'Bintang' THEN 'Spectroscopy'
        WHEN ao.type = 'Galaksi' AND ao.name IN ('Andromeda', 'Milky Way') THEN 'Visual Observation'
        WHEN ao.type = 'Galaksi' THEN 'Telescope Observation'
        ELSE 'Unknown'
    END AS discovery_method,
    
    -- Notes tetap sama
    CASE 
        WHEN ao.name LIKE 'Kepler-%' THEN 'Discovered by NASA Kepler mission'
        WHEN ao.name LIKE 'WASP-%' THEN 'Discovered by WASP project'
        WHEN ao.name LIKE 'TRAPPIST-%' THEN 'Discovered by TRAPPIST telescope'
        WHEN ao.name LIKE 'K2-%' THEN 'Discovered by K2 mission'
        WHEN ao.name LIKE 'TOI-%' THEN 'Discovered by TESS'
        WHEN ao.name = 'Gliese 581g' THEN 'Controversial exoplanet discovery'
        ELSE 'Standard astronomical observation'
    END AS notes
FROM AstronomicalObject ao;

-- Link discoveries to discoverers
INSERT INTO DiscoveryDiscoverer (discovery_id, discoverer_id)
SELECT 
    d.id,
    CASE 
        WHEN ao.name LIKE 'Kepler-%' THEN 6
        WHEN ao.name LIKE 'TRAPPIST-%' THEN 7
        WHEN ao.name LIKE 'K2-%' THEN 8
        WHEN ao.name LIKE 'TOI-%' THEN 9
        WHEN ao.name LIKE 'WASP-%' THEN 3
        WHEN ao.name LIKE 'HD %' THEN 10
        WHEN ao.name LIKE 'Gliese %' THEN 7  -- Ganti 16 dengan 7 (TRAPPIST Team)
        WHEN ao.name LIKE 'CoRoT-%' THEN 11
        WHEN ao.name LIKE 'HAT-P-%' THEN 12
        WHEN ao.name LIKE 'XO-%' THEN 13
        WHEN ao.name LIKE 'TrES-%' THEN 14
        WHEN ao.name LIKE 'OGLE-%' THEN 15
        WHEN ao.type = 'Galaksi' AND ao.name IN ('Andromeda', 'Milky Way') THEN 4
        WHEN ao.type = 'Bintang' AND ao.name IN ('Sirius', 'Proxima Centauri', 'Betelgeuse', 'Vega', 'Rigel', 'Capella', 'Arcturus', 'Aldebaran', 'Spica', 'Antares', 'Pollux', 'Fomalhaut', 'Deneb', 'Regulus', 'Canopus', 'Alpha Centauri A', 'Alpha Centauri B', 'Barnard''s Star', 'Wolf 359', 'Lalande 21185', 'Luyten 726-8A', 'Epsilon Eridani', 'Procyon A', '61 Cygni A', 'Tau Ceti', '40 Eridani A', 'HD 164595') THEN 4
        ELSE 1
    END
FROM Discovery d
JOIN AstronomicalObject ao ON d.object_id = ao.id;

-- Insert sample observations
INSERT INTO Observation (object_id, observatory_id, observation_date, instrument, wavelength, exposure_time, notes)
SELECT 
    ao.id,
    CASE 
        WHEN ao.type = 'Planet' THEN 2
        WHEN ao.type = 'Bintang' THEN 5
        WHEN ao.type = 'Galaksi' THEN 1
        ELSE 3
    END AS observatory_id,
    CASE 
        WHEN ao.type = 'Planet' THEN '2023-01-15 12:00:00'::TIMESTAMP
        WHEN ao.type = 'Bintang' THEN '2022-06-10 20:30:00'::TIMESTAMP
        WHEN ao.type = 'Galaksi' THEN '2021-12-05 02:15:00'::TIMESTAMP
        ELSE '2023-03-01 15:45:00'::TIMESTAMP
    END AS observation_date,
    CASE 
        WHEN ao.type = 'Planet' THEN 'CCD Photometer'
        WHEN ao.type = 'Bintang' THEN 'Spectrograph'
        WHEN ao.type = 'Galaksi' THEN 'Hubble ACS'
        ELSE 'Standard Telescope'
    END AS instrument,
    CASE 
        WHEN ao.type = 'Planet' THEN 'Optical'
        WHEN ao.type = 'Bintang' THEN 'Visible'
        WHEN ao.type = 'Galaksi' THEN 'UV/Optical'
        ELSE 'Broadband'
    END AS wavelength,
    CASE 
        WHEN ao.type = 'Planet' THEN '300s'
        WHEN ao.type = 'Bintang' THEN '600s'
        WHEN ao.type = 'Galaksi' THEN '1200s'
        ELSE '900s'
    END AS exposure_time,
    CASE 
        WHEN ao.name = 'Kepler-452b' THEN 'Earth-like planet in habitable zone'
        WHEN ao.name = 'Proxima Centauri' THEN 'Nearest star to Earth'
        WHEN ao.name = 'Andromeda' THEN 'Nearest major galaxy'
        ELSE 'Standard observation'
    END AS notes
FROM AstronomicalObject ao
WHERE ao.id <= 20;

INSERT INTO Photo (object_id, url, caption, taken_date, telescope, instrument, wavelength_filter, is_primary)
VALUES
-- Stars (Bintang)
-- 1. Sirius
((SELECT id FROM AstronomicalObject WHERE name = 'Sirius'), 'https://cdn.esahubble.org/archives/images/wallpaper5/heic0516a.jpg', 'Sirius - Bintang terterang di langit malam', '2023-01-15', 'Hubble Space Telescope', 'ACS/WFC', 'F606W', true),
-- 2. Proxima Centauri
((SELECT id FROM AstronomicalObject WHERE name = 'Proxima Centauri'), 'https://cdn.esahubble.org/archives/images/wallpaper5/potw1343a.jpg', 'Proxima Centauri - Bintang terdekat dengan Bumi', '2023-01-16', 'ESO Very Large Telescope', 'FORS2', 'V-band', true),
-- 3. Betelgeuse
((SELECT id FROM AstronomicalObject WHERE name = 'Betelgeuse'), 'https://science.nasa.gov/wp-content/uploads/2023/06/betelgeuse-location-and-size.png', 'Betelgeuse - Supergiant raksasa merah', '2023-01-17', 'Hubble Space Telescope', 'WFC3/UVIS', 'F658N', true),
-- 4. Vega
((SELECT id FROM AstronomicalObject WHERE name = 'Vega'), 'https://sm.mashable.com/mashable_sea/photo/default/images-1_dbqy.jpg', 'Vega - Bintang utama rasi Lyra', '2023-01-18', 'Hubble Space Telescope', 'STIS', 'Optical', true),
-- 5. Rigel
((SELECT id FROM AstronomicalObject WHERE name = 'Rigel'), 'https://cdn.mos.cms.futurecdn.net/BycSddSPZowex8XeNvo2E8.jpg', 'Rigel - Supergiant biru terang di Orion', '2023-01-19', 'Hubble Space Telescope', 'ACS/WFC', 'F435W', true),
-- 10. Capella
((SELECT id FROM AstronomicalObject WHERE name = 'Capella'), 'https://www.constellation-guide.com/wp-content/uploads/2014/08/Capella-size.png', 'Capella - Sistem bintang ganda', '2023-01-20', 'Hubble Space Telescope', 'ACS/WFC', 'F555W', true),
-- 11. Arcturus
((SELECT id FROM AstronomicalObject WHERE name = 'Arcturus'), 'https://cdn.mos.cms.futurecdn.net/rDubZBD2ryyFooKzbeRu9G-1200-80.jpg', 'Arcturus - Bintang raksasa oranye', '2023-01-21', 'Hubble Space Telescope', 'STIS', 'Optical', true),
-- 12. Aldebaran
((SELECT id FROM AstronomicalObject WHERE name = 'Aldebaran'), 'https://cdn.mos.cms.futurecdn.net/E8V4MQrD8g6m7PpPgS4RCk.jpg', 'Aldebaran - Mata bintang Taurus', '2023-01-22', 'Hubble Space Telescope', 'WFC3/UVIS', 'F814W', true),
-- 13. Spica
((SELECT id FROM AstronomicalObject WHERE name = 'Spica'), 'https://science.nasa.gov/wp-content/uploads/2024/10/hubble-raquarii-stsci-01j80b5p0qfsrzn9a2e48f61cx.jpg?w=1536', 'Spica - Bintang ganda dekat ekuator', '2023-01-23', 'Hubble Space Telescope', 'ACS/WFC', 'F475W', true),
-- 14. Antares
((SELECT id FROM AstronomicalObject WHERE name = 'Antares'), 'https://i.guim.co.uk/img/media/1e5e45865dd392fb368aefc7e28436ad5adc091f/0_6_3840_2303/master/3840.jpg?width=1200&height=900&quality=85&auto=format&fit=crop&s=697b11891e712854379336d432c4530d', 'Antares - Supergiant merah di Scorpius', '2023-01-24', 'Hubble Space Telescope', 'WFC3/IR', 'F160W', true),
-- 15. Pollux
((SELECT id FROM AstronomicalObject WHERE name = 'Pollux'), 'https://assets.newsweek.com/wp-content/uploads/2025/08/633748-7-7-17-hubble-2.png?w=1600&h=900&q=88', 'Pollux - Bintang raksasa oranye', '2023-01-25', 'Hubble Space Telescope', 'STIS', 'Optical', true),
-- 16. Fomalhaut
((SELECT id FROM AstronomicalObject WHERE name = 'Fomalhaut'), 'https://cdn.eso.org/images/large/potw1721a.jpg', 'Fomalhaut - Bintang muda dengan debris disk', '2023-01-26', 'Hubble Space Telescope', 'ACS/WFC', 'F606W', true),
-- 17. Deneb
((SELECT id FROM AstronomicalObject WHERE name = 'Deneb'), 'https://theplanets.org/123/2021/01/Cygnus-2.png', 'Deneb - Supergiant putih di Cygnus', '2023-01-27', 'Hubble Space Telescope', 'STIS', 'Optical', true),
-- 18. Regulus
((SELECT id FROM AstronomicalObject WHERE name = 'Regulus'), 'https://www.constellation-guide.com/wp-content/uploads/2015/04/Regulus.webp', 'Regulus - Bintang utama Leo', '2023-01-28', 'Hubble Space Telescope', 'ACS/WFC', 'F435W', true),
-- 19. Canopus
((SELECT id FROM AstronomicalObject WHERE name = 'Canopus'), 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Canopus.jpg/1200px-Canopus.jpg', 'Canopus - Bintang terterang kedua', '2023-01-29', 'Hubble Space Telescope', 'STIS', 'Optical', true),
-- 40. Alpha Centauri A
((SELECT id FROM AstronomicalObject WHERE name = 'Alpha Centauri A'), 'https://cdn.eso.org/images/large/eso0542a.jpg', 'Alpha Centauri A - Komponen utama sistem Alpha Centauri', '2023-01-30', 'ESO Very Large Telescope', 'FORS2', 'V-band', true),
-- 41. Alpha Centauri B
((SELECT id FROM AstronomicalObject WHERE name = 'Alpha Centauri B'), 'https://cdn.eso.org/images/screen/eso1241b.jpg', 'Alpha Centauri B - Komponen kedua sistem Alpha Centauri', '2023-01-31', 'ESO Very Large Telescope', 'FORS2', 'V-band', true),
-- 42. Barnard's Star
((SELECT id FROM AstronomicalObject WHERE name = 'Barnard''s Star'), 'https://telescope.live/sites/default/files/styles/front_page_obs_w696_h452/public/2022-03/Hubble%20Image.jpg?itok=KPyfATW4', 'Barnard''s Star - Bintang dengan proper motion tinggi', '2023-02-01', 'Hubble Space Telescope', 'WFC3/UVIS', 'F606W', true),
-- 43. Wolf 359
((SELECT id FROM AstronomicalObject WHERE name = 'Wolf 359'), 'https://chandra.harvard.edu/photo/2025/wolf359/wolf359_lg.jpg', 'Wolf 359 - Red dwarf terdekat ketiga', '2023-02-02', 'Hubble Space Telescope', 'ACS/WFC', 'F814W', true),
-- 44. Lalande 21185
((SELECT id FROM AstronomicalObject WHERE name = 'Lalande 21185'), 'https://www.astronomy.com/wp-content/uploads/2023/12/ASY-MB0124-Lalande-21185-.jpg', 'Lalande 21185 - Bintang red dwarf', '2023-02-03', 'Hubble Space Telescope', 'STIS', 'Optical', true),
-- 45. Luyten 726-8A
((SELECT id FROM AstronomicalObject WHERE name = 'Luyten 726-8A'), 'https://chview.nova.org/solcom/stars/uv-ceti2.jpg', 'Luyten 726-8A - Bintang flare UV Ceti', '2023-02-04', 'Hubble Space Telescope', 'ACS/WFC', 'F658N', true),
-- 46. Epsilon Eridani
((SELECT id FROM AstronomicalObject WHERE name = 'Epsilon Eridani'), 'http://cdn.esahubble.org/archives/images/screen/heic0613b.jpg', 'Epsilon Eridani - Bintang dengan planet dan debris disk', '2023-02-05', 'Hubble Space Telescope', 'ACS/WFC', 'F606W', true),
-- 47. Procyon A
((SELECT id FROM AstronomicalObject WHERE name = 'Procyon A'), 'https://chview.nova.org/solcom/stars/procyon0.jpg', 'Procyon A - Bintang subgiant putih-kuning', '2023-02-06', 'Hubble Space Telescope', 'STIS', 'Optical', true),
-- 48. 61 Cygni A
((SELECT id FROM AstronomicalObject WHERE name = '61 Cygni A'), 'https://images.fineartamerica.com/images-medium-large/61-cygni-planet-chris-butler.jpg', '61 Cygni A - Bintang orange dwarf', '2023-02-07', 'Hubble Space Telescope', 'ACS/WFC', 'F555W', true),
-- 49. Tau Ceti
((SELECT id FROM AstronomicalObject WHERE name = 'Tau Ceti'), 'https://cdn.sci.news/images/2012/12/image_785_1.jpg', 'Tau Ceti - Bintang mirip matahari', '2023-02-08', 'Hubble Space Telescope', 'STIS', 'Optical', true),
-- 50. 40 Eridani A
((SELECT id FROM AstronomicalObject WHERE name = '40 Eridani A'), 'https://assets.science.nasa.gov/dynamicimage/assets/science/missions/hubble/releases/2018/10/STScI-01EVSZKC0K3NW943ZGXF2YZ979.tif?w=3840&h=2160&fit=clip&crop=faces%2Cfocalpoint', '40 Eridani A - Bintang orange dwarf', '2023-02-09', 'Hubble Space Telescope', 'ACS/WFC', 'F606W', true),
-- 51. HD 164595
((SELECT id FROM AstronomicalObject WHERE name = 'HD 164595'), 'https://assets.science.nasa.gov/dynamicimage/assets/science/missions/hubble/artist-concepts/hubbleart_52.jpg?w=1024', 'HD 164595 - Bintang tipe G mirip matahari', '2023-02-10', 'Hubble Space Telescope', 'STIS', 'Optical', true),
-- Planets
-- 5. Kepler-452b
((SELECT id FROM AstronomicalObject WHERE name = 'Kepler-452b'), 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ed/Kepler-452b_artist_concept.jpg/2560px-Kepler-452b_artist_concept.jpg', 'Kepler-452b - Planet Bumi-like di zona habitable', '2023-03-01', 'Kepler Space Telescope', 'CCD Photometer', 'Optical', true),
-- 6. HD 209458b
((SELECT id FROM AstronomicalObject WHERE name = 'HD 209458b'), 'https://assets.science.nasa.gov/dynamicimage/assets/science/missions/hubble/releases/2001/11/STScI-01EVVFFBQNRPZDCFX2D7A078Z5.tif?w=3300&h=2529&fit=clip&crop=faces%2Cfocalpoint', 'HD 209458b - Hot Jupiter Osiris', '2023-03-02', 'Hubble Space Telescope', 'STIS', 'Optical', true),
-- 7. Gliese 581g
((SELECT id FROM AstronomicalObject WHERE name = 'Gliese 581g'), 'https://cdn.eso.org/images/screen/eso0722a.jpg', 'Gliese 581g - Super-Earth di zona habitable', '2023-03-03', 'ESO Very Large Telescope', 'HARPS', 'Optical', true),
-- 8. WASP-12b
((SELECT id FROM AstronomicalObject WHERE name = 'WASP-12b'), 'https://cdn.mos.cms.futurecdn.net/teUbfLqDoaSqMThbK68A6d-1200-80.png', 'WASP-12b - Ultra-hot Jupiter', '2023-03-04', 'Hubble Space Telescope', 'WFC3/UVIS', 'F275W', true),
-- 20. Kepler-186f
((SELECT id FROM AstronomicalObject WHERE name = 'Kepler-186f'), 'https://assets.science.nasa.gov/content/dam/science/missions/webb/outreach/migrated/2018/STScI-01FKNX1XE4N5CDDB5Q1ZJEB0JQ.png', 'Kepler-186f - Planet Bumi-size di zona habitable', '2023-03-05', 'Kepler Space Telescope', 'CCD Photometer', 'Optical', true),
-- 21. TRAPPIST-1e
((SELECT id FROM AstronomicalObject WHERE name = 'TRAPPIST-1e'), 'https://assets.science.nasa.gov/dynamicimage/assets/science/missions/webb/science/2025/09/STScI-01K1V61D55HJV2956SNSEN15GN.tif?w=3840&h=2160&fit=clip&crop=faces%2Cfocalpoint', 'TRAPPIST-1e - Planet Bumi-like di sistem TRAPPIST-1', '2023-03-06', 'TRAPPIST Telescope', 'CCD Camera', 'Near-IR', true),
-- 22. K2-18b
((SELECT id FROM AstronomicalObject WHERE name = 'K2-18b'), 'https://cdn.esahubble.org/archives/images/publicationjpg/heic1916a.jpg', 'K2-18b - Super-Earth dengan atmosfer air', '2023-03-07', 'Hubble Space Telescope', 'WFC3/IR', 'F139M', true),
-- 23. TOI-715b
((SELECT id FROM AstronomicalObject WHERE name = 'TOI-715b'), 'https://cdn.sci.news/images/enlarge11/image_12658e-TOI-715b.jpg', 'TOI-715b - Super-Earth di zona habitable', '2023-03-08', 'TESS Space Telescope', 'CCD Photometer', 'Optical', true),
-- 24. 55 Cancri e
((SELECT id FROM AstronomicalObject WHERE name = '55 Cancri e'), 'https://scitechdaily.com/images/Hubble-Reveals-Planet-with-Super-Earth-Atmosphere.jpg', '55 Cancri e - Super-Earth berlian', '2023-03-09', 'Hubble Space Telescope', 'WFC3/UVIS', 'F275W', true),
-- 25. CoRoT-7b
((SELECT id FROM AstronomicalObject WHERE name = 'CoRoT-7b'), 'https://cdn.eso.org/images/screen/eso0933a.jpg', 'CoRoT-7b - Super-Earth lava', '2023-03-10', 'CoRoT Space Telescope', 'CCD Photometer', 'Optical', true),
-- 26. Kepler-16b
((SELECT id FROM AstronomicalObject WHERE name = 'Kepler-16b'), 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/Kepler-16.jpg/1200px-Kepler-16.jpg', 'Kepler-16b - Planet circumbinary', '2023-03-11', 'Kepler Space Telescope', 'CCD Photometer', 'Optical', true),
-- 27. HAT-P-7b
((SELECT id FROM AstronomicalObject WHERE name = 'HAT-P-7b'), 'https://cdn.mos.cms.futurecdn.net/2TvawuBKbmrm7Ut9eDNqWU.png', 'HAT-P-7b - Hot Jupiter', '2023-03-12', 'HATNet Project', 'CCD Camera', 'Optical', true),
-- 28. XO-3b
((SELECT id FROM AstronomicalObject WHERE name = 'XO-3b'), 'https://assets.science.nasa.gov/dynamicimage/assets/science/psd/photojournal/pia/pia20/pia20056/PIA20056.jpg?w=6000&h=3663&fit=clip&crop=faces%2Cfocalpoint', 'XO-3b - Massive hot Jupiter', '2023-03-13', 'XO Project', 'CCD Camera', 'Optical', true),
-- 29. WASP-33b
((SELECT id FROM AstronomicalObject WHERE name = 'WASP-33b'), 'https://science.nasa.gov/wp-content/uploads/2023/04/hot_jupiter_exoplanets-jpg.webp', 'WASP-33b - Ultra-hot Jupiter', '2023-03-14', 'WASP Project', 'CCD Camera', 'Optical', true),
-- 52. Kepler-442b
((SELECT id FROM AstronomicalObject WHERE name = 'Kepler-442b'), 'https://eu-images.contentstack.com/v3/assets/blt949ea8e16e463049/blt6eec22ce1244f3af/661978129f83f3540ef6bb19/earth-planet.jpg', 'Kepler-442b - Super-Earth di zona habitable', '2023-03-15', 'Kepler Space Telescope', 'CCD Photometer', 'Optical', true),
-- 53. Kepler-438b
((SELECT id FROM AstronomicalObject WHERE name = 'Kepler-438b'), 'https://i.guim.co.uk/img/static/sys-images/Guardian/Pix/pictures/2014/4/17/1397748997367/Kepler-186f-012.jpg?width=445&dpr=1&s=none&crop=none', 'Kepler-438b - Planet Bumi-size', '2023-03-16', 'Kepler Space Telescope', 'CCD Photometer', 'Optical', true),
-- 54. HD 40307g
((SELECT id FROM AstronomicalObject WHERE name = 'HD 40307g'), 'https://www.astronomy.com/wp-content/uploads/2023/02/triple_sup_earth_900.jpg', 'HD 40307g - Super-Earth di zona habitable', '2023-03-17', 'HARPS Spectrograph', 'ESO 3.6m Telescope', 'Optical', true),
-- 55. Gliese 667Cc
((SELECT id FROM AstronomicalObject WHERE name = 'Gliese 667Cc'), 'https://cdn.mos.cms.futurecdn.net/bFHQ7VqHs9AHgkgFuZg8vi-1200-80.jpg', 'Gliese 667Cc - Super-Earth di zona habitable', '2023-03-18', 'ESO Very Large Telescope', 'HARPS', 'Optical', true),
-- 56. Kepler-22b
((SELECT id FROM AstronomicalObject WHERE name = 'Kepler-22b'), 'https://d2pn8kiwq2w21t.cloudfront.net/original_images/jpegPIA14883.jpg', 'Kepler-22b - Super-Earth di zona habitable', '2023-03-19', 'Kepler Space Telescope', 'CCD Photometer', 'Optical', true),
-- 57. WASP-121b
((SELECT id FROM AstronomicalObject WHERE name = 'WASP-121b'), 'https://assets.science.nasa.gov/content/dam/science/missions/hubble/releases/2024/01/STScI-01HHJ0WBF5N3MWXANYPCH06KBK.tif/jcr:content/renditions/4000x2500.jpg', 'WASP-121b - Ultra-hot Jupiter', '2023-03-20', 'Hubble Space Telescope', 'WFC3/UVIS', 'F275W', true),
-- 58. Kepler-10b
((SELECT id FROM AstronomicalObject WHERE name = 'Kepler-10b'), 'https://cdn.mos.cms.futurecdn.net/MrFak2Uytx376pkK8KUNLY.jpg', 'Kepler-10b - Planet lava', '2023-03-21', 'Kepler Space Telescope', 'CCD Photometer', 'Optical', true),
-- 59. GJ 1214b
((SELECT id FROM AstronomicalObject WHERE name = 'GJ 1214b'), 'https://assets.science.nasa.gov/dynamicimage/assets/science/missions/hubble/releases/2013/12/STScI-01EVVM4G8ZMDQJTZZS59GS5MFD.tif?w=4000&h=3000&fit=clip&crop=faces%2Cfocalpoint', 'GJ 1214b - Super-Earth dengan atmosfer tebal', '2023-03-22', 'Hubble Space Telescope', 'WFC3/IR', 'F139M', true),
-- 60. Kepler-7b
((SELECT id FROM AstronomicalObject WHERE name = 'Kepler-7b'), 'https://news.mit.edu/sites/default/files/styles/news_article__image_gallery/public/images/201310/20131002174832-0_0.jpg?itok=6ThoMfUJ', 'Kepler-7b - Hot Jupiter dengan albedo tinggi', '2023-03-23', 'Kepler Space Telescope', 'CCD Photometer', 'Optical', true),
-- 61. TrES-2b
((SELECT id FROM AstronomicalObject WHERE name = 'TrES-2b'), 'https://cdn.mos.cms.futurecdn.net/v2/t:126,l:0,cw:575,ch:323,q:80,w:575/FiF6AbB5jJXCpV4UtUgmrj.jpg', 'TrES-2b - Planet tergelap', '2023-03-24', 'TrES Project', 'CCD Camera', 'Optical', true),
-- 62. OGLE-TR-56b
((SELECT id FROM AstronomicalObject WHERE name = 'OGLE-TR-56b'), 'https://alchetron.com/cdn/ogle-tr-56b-e9c49d31-d189-4e1f-876c-9a58218befd-resize-750.jpeg', 'OGLE-TR-56b - Hot Jupiter', '2023-03-25', 'OGLE Project', 'CCD Camera', 'Optical', true),
-- 63. WASP-43b
((SELECT id FROM AstronomicalObject WHERE name = 'WASP-43b'), 'https://www.popsci.com/wp-content/uploads/2024/05/01/1_webb_repost_miri_wasp_43_b.width-1320.png?quality=85', 'WASP-43b - Hot Jupiter dengan orbit pendek', '2023-03-26', 'WASP Project', 'CCD Camera', 'Optical', true),
-- 64. HAT-P-1b
((SELECT id FROM AstronomicalObject WHERE name = 'HAT-P-1b'), 'https://assets.science.nasa.gov/dynamicimage/assets/science/psd/photojournal/pia/pia20/pia20056/PIA20056.jpg?w=6000&h=3663&fit=clip&crop=faces%2Cfocalpoint', 'HAT-P-1b - Hot Jupiter dengan radius besar', '2023-03-27', 'HATNet Project', 'CCD Camera', 'Optical', true),
-- 65. XO-1b
((SELECT id FROM AstronomicalObject WHERE name = 'XO-1b'), 'https://assets.science.nasa.gov/dynamicimage/assets/science/missions/hubble/releases/2001/11/STScI-01EVVFFBQNRPZDCFX2D7A078Z5.tif?w=3300&h=2529&fit=clip&crop=faces%2Cfocalpoint', 'XO-1b - Hot Jupiter', '2023-03-28', 'XO Project', 'CCD Camera', 'Optical', true),
-- 66. TrES-1b
((SELECT id FROM AstronomicalObject WHERE name = 'TrES-1b'), 'https://assets.science.nasa.gov/dynamicimage/assets/science/psd/photojournal/pia/pia20/pia20056/PIA20056.jpg?w=6000&h=3663&fit=clip&crop=faces%2Cfocalpoint', 'TrES-1b - Hot Jupiter', '2023-03-29', 'TrES Project', 'CCD Camera', 'Optical', true),
-- 67. WASP-17b
((SELECT id FROM AstronomicalObject WHERE name = 'WASP-17b'), 'https://assets.science.nasa.gov/content/dam/science/missions/webb/science/2023/10/STScI-01HC3AY82PXH352B641ZRYNNNS.png/jcr:content/renditions/1920x1080.jpg', 'WASP-17b - Hot Jupiter dengan orbit retrograde', '2023-03-30', 'WASP Project', 'CCD Camera', 'Optical', true),
-- 68. CoRoT-1b
((SELECT id FROM AstronomicalObject WHERE name = 'CoRoT-1b'), 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/CoRoT-1.jpg/250px-CoRoT-1.jpg', 'CoRoT-1b - Hot Jupiter', '2023-03-31', 'CoRoT Space Telescope', 'CCD Photometer', 'Optical', true),
-- Galaxies
-- 9. Andromeda
((SELECT id FROM AstronomicalObject WHERE name = 'Andromeda'), 'https://svs.gsfc.nasa.gov/vis/a030000/a030900/a030995/STScI-H-Sombrero_VIS-1920x1080.png', 'Andromeda - Galaksi spiral terdekat', '2023-04-01', 'Hubble Space Telescope', 'ACS/WFC', 'F606W', true),
-- 30. Milky Way
((SELECT id FROM AstronomicalObject WHERE name = 'Milky Way'), 'https://svs.gsfc.nasa.gov/vis/a030000/a030900/a030961/STScI-H-MWC_combined-3840x2160.png', 'Milky Way - Galaksi Bima Sakti kita', '2023-04-02', 'Various Observatories', 'Composite', 'Multi-band', true),
-- 31. Large Magellanic Cloud
((SELECT id FROM AstronomicalObject WHERE name = 'Large Magellanic Cloud'), 'http://cdn.esahubble.org/archives/images/screen/heic1301a.jpg', 'Large Magellanic Cloud - Galaksi satelit Bima Sakti', '2023-04-03', 'Hubble Space Telescope', 'ACS/WFC', 'F658N', true),
-- 32. Small Magellanic Cloud
((SELECT id FROM AstronomicalObject WHERE name = 'Small Magellanic Cloud'), 'https://svs.gsfc.nasa.gov/vis/a030000/a030400/a030467/under_wing_small_magellanic_cloud_cal.png', 'Small Magellanic Cloud - Galaksi satelit Bima Sakti', '2023-04-04', 'Hubble Space Telescope', 'ACS/WFC', 'F606W', true),
-- 33. Triangulum
((SELECT id FROM AstronomicalObject WHERE name = 'Triangulum'), 'https://science.nasa.gov/wp-content/uploads/2023/04/heic1901a-jpg.webp', 'Triangulum - Galaksi spiral M33', '2023-04-05', 'Hubble Space Telescope', 'ACS/WFC', 'F555W', true),
-- 34. Whirlpool
((SELECT id FROM AstronomicalObject WHERE name = 'Whirlpool'), 'https://cdn.esahubble.org/archives/images/publicationjpg/heic0506a.jpg', 'Whirlpool - Galaksi spiral interaksi M51', '2023-04-06', 'Hubble Space Telescope', 'ACS/WFC', 'F435W', true),
-- 35. Sombrero
((SELECT id FROM AstronomicalObject WHERE name = 'Sombrero'), 'https://science.nasa.gov/wp-content/uploads/2023/04/sombrero-galaxy-hubble-jpg.webp', 'Sombrero - Galaksi spiral M104', '2023-04-07', 'Hubble Space Telescope', 'ACS/WFC', 'F606W', true),
-- 36. Centaurus A
((SELECT id FROM AstronomicalObject WHERE name = 'Centaurus A'), 'https://assets.science.nasa.gov/content/dam/science/missions/hubble/releases/1998/05/STScI-01EVTAAWVPJZJVTZW26K9YH645.jpg', 'Centaurus A - Galaksi aktif NGC 5128', '2023-04-08', 'Hubble Space Telescope', 'ACS/WFC', 'F814W', true),
-- 37. Pinwheel
((SELECT id FROM AstronomicalObject WHERE name = 'Pinwheel'), 'https://svs.gsfc.nasa.gov/vis/a030000/a030900/a030969/STScI-H-M101-VIS_3840x2160.png', 'Pinwheel - Galaksi spiral M101', '2023-04-09', 'Hubble Space Telescope', 'ACS/WFC', 'F475W', true),
-- 38. Messier 87
((SELECT id FROM AstronomicalObject WHERE name = 'Messier 87'), 'https://photos.smugmug.com/Astrophotography/Galaxies/i-h3twqX2/0/MSRWFd38N6n49XwH97B8pwnmvZkKXjgV4n8jbc4ng/XL/M87_LRGB_v31_GlobularsAnnotated-XL.jpg', 'Messier 87 - Galaksi eliptis raksasa dengan black hole', '2023-04-10', 'Hubble Space Telescope', 'ACS/WFC', 'F606W', true),
-- 39. NGC 1300
((SELECT id FROM AstronomicalObject WHERE name = 'NGC 1300'), 'https://assets.science.nasa.gov/content/dam/science/missions/hubble/releases/2005/01/STScI-01EVT8DP1YM9FYPF0Y33VY7ANB.tif/jcr:content/renditions/6637x3787.jpg', 'NGC 1300 - Galaksi spiral barred', '2023-04-11', 'Hubble Space Telescope', 'ACS/WFC', 'F555W', true);

-- Create indexes for better performance
CREATE INDEX idx_astronomical_object_name ON AstronomicalObject(name);
CREATE INDEX idx_astronomical_object_type ON AstronomicalObject(type);
CREATE INDEX idx_astronomical_object_habitable ON AstronomicalObject(is_habitable);
CREATE INDEX idx_star_details_spectral_class ON StarDetails(spectral_class);
CREATE INDEX idx_discovery_date ON Discovery(discovery_date);
CREATE INDEX idx_observation_date ON Observation(observation_date);
CREATE INDEX idx_observation_object ON Observation(object_id);
CREATE INDEX idx_photo_object ON Photo(object_id);
CREATE INDEX idx_photo_primary ON Photo(is_primary);

-- Create views for common queries
CREATE VIEW view_habitable_objects AS
SELECT 
    ao.*,
    sd.spectral_class,
    sd.luminosity,
    sd.radius_solar
FROM AstronomicalObject ao
LEFT JOIN StarDetails sd ON ao.id = sd.object_id
WHERE ao.is_habitable = true;

CREATE VIEW view_stars_with_details AS
SELECT 
    ao.*,
    sd.spectral_class,
    sd.luminosity,
    sd.radius_solar
FROM AstronomicalObject ao
JOIN StarDetails sd ON ao.id = sd.object_id
WHERE ao.type = 'Bintang';

CREATE VIEW view_exoplanets AS
SELECT 
    ao.*,
    d.discovery_date,
    d.discovery_method,
    STRING_AGG(disc.name, ', ') AS discoverers
FROM AstronomicalObject ao
JOIN Discovery d ON ao.id = d.object_id
JOIN DiscoveryDiscoverer dd ON d.id = dd.discovery_id
JOIN Discoverer disc ON dd.discoverer_id = disc.id
WHERE ao.type = 'Planet'
GROUP BY ao.id, d.discovery_date, d.discovery_method;

CREATE VIEW view_galaxies AS
SELECT 
    ao.*,
    d.discovery_date,
    d.discovery_method,
    STRING_AGG(disc.name, ', ') AS discoverers
FROM AstronomicalObject ao
JOIN Discovery d ON ao.id = d.object_id
JOIN DiscoveryDiscoverer dd ON d.id = dd.discovery_id
JOIN Discoverer disc ON dd.discoverer_id = disc.id
WHERE ao.type = 'Galaksi'
GROUP BY ao.id, d.discovery_date, d.discovery_method;

-- Create functions for common operations
CREATE OR REPLACE FUNCTION get_object_photos(object_name VARCHAR)
RETURNS TABLE(photo_id INTEGER, url VARCHAR, caption TEXT, taken_date DATE, telescope VARCHAR) AS $$ BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.url,
        p.caption,
        p.taken_date,
        p.telescope
    FROM Photo p
    JOIN AstronomicalObject ao ON p.object_id = ao.id
    WHERE ao.name = object_name
    ORDER BY p.taken_date DESC;
END;
 $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_object_observations(object_name VARCHAR)
RETURNS TABLE(observation_id INTEGER, observatory_name VARCHAR, observation_date TIMESTAMP, instrument VARCHAR, notes TEXT) AS $$ BEGIN
    RETURN QUERY
    SELECT 
        o.id,
        obs.name,
        o.observation_date,
        o.instrument,
        o.notes
    FROM Observation o
    JOIN AstronomicalObject ao ON o.object_id = ao.id
    JOIN Observatory obs ON o.observatory_id = obs.id
    WHERE ao.name = object_name
    ORDER BY o.observation_date DESC;
END;
 $$ LANGUAGE plpgsql;

-- Grant permissions (adjust as needed for your web application)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO PUBLIC;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO PUBLIC;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO PUBLIC;

-- Display summary
DO $$ DECLARE
    total_objects INTEGER;
    total_stars INTEGER;
    total_planets INTEGER;
    total_galaxies INTEGER;
    total_habitable INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_objects FROM AstronomicalObject;
    SELECT COUNT(*) INTO total_stars FROM AstronomicalObject WHERE type = 'Bintang';
    SELECT COUNT(*) INTO total_planets FROM AstronomicalObject WHERE type = 'Planet';
    SELECT COUNT(*) INTO total_galaxies FROM AstronomicalObject WHERE type = 'Galaksi';
    SELECT COUNT(*) INTO total_habitable FROM AstronomicalObject WHERE is_habitable = true;
    
    RAISE NOTICE 'Database Setup Complete!';
    RAISE NOTICE 'Total Objects: %', total_objects;
    RAISE NOTICE 'Stars: %', total_stars;
    RAISE NOTICE 'Planets: %', total_planets;
    RAISE NOTICE 'Galaxies: %', total_galaxies;
    RAISE NOTICE 'Habitable Objects: %', total_habitable;
    RAISE NOTICE 'Your astronomical database is now ready for web integration!';
END $$;