library(microdatasus)
library(arrow)
library(here)

# Define the time range for the data download
year <- 2024
months <- 1:12

# Define the base directory
parquet_dir <- here("data", "sih", "2024")
dir.create(parquet_dir, recursive = TRUE, showWarnings = FALSE)

# Loop through each month of 2024
for (month in months) {

  # Define the output file path
  month_str <- sprintf("%02d", month)
  parquet_file <- file.path(parquet_dir,
                            paste0("SIH_RD_ALL_UF",
                                   year, "_", month_str, ".parquet"))

  # Skip the process if the file already exists
  if (file.exists(parquet_file)) next

  # Fetch_datasus downloads data for ALL UFs for the specified month/2024
  sih_raw <- fetch_datasus(
    year_start = year, year_end = year,
    month_start = month, month_end = month,
    uf = "all", information_system = "SIH-RD"
  )

  # Process data
  sih_data <- process_sih(sih_raw)

  # Save data to parquet files
  write_parquet(
    sih_data,
    sink = parquet_file,
    compression = "zstd"
  )
}

# Read all Parquet files
dataset <- open_dataset(parquet_dir)

# Show the schema to verify column names and data types
print(dataset$schema)

# Show the first few rows to visually inspect the data
sih_head <- dataset |>
  head(10) |>
  dplyr::collect()

print(sih_head)