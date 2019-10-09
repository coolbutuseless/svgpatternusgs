
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 02 - Convert to raw <pattern></pattern> rather than <svg></svg>
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
input_dir <- "data-raw/02-svg-pattern-raw/"
svg_files <- list.files(input_dir, full.names = TRUE)


if (TRUE) {
  dir.create("./inst/patterns", showWarnings = FALSE)
  zip_file <- './inst/patterns/usgs_svg_patterns.zip'
  system2("zip", c('-q', '-r', '-9', '-j', zip_file, input_dir))
}

all_usgs_filenames   <- basename(svg_files)
all_usgs_pattern_ids <- paste0("usgs-", tools::file_path_sans_ext(basename(svg_files)))
all_usgs_codes       <- as.integer(tools::file_path_sans_ext(all_usgs_filenames))



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Repeating codes so that it appears as if we have 256 possible codes.
# makes some logic easier
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
padded_usgs_codes <- c(all_usgs_codes, all_usgs_codes)[1:256]




#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Internal data
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
usethis::use_data(all_usgs_filenames, all_usgs_pattern_ids,
                  internal = TRUE, overwrite = TRUE)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# External data
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
usethis::use_data(all_usgs_codes, internal = FALSE, overwrite = TRUE)