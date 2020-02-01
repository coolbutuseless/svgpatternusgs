
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' All valid USGS codes
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"all_usgs_codes"



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Change the attributes of a pattern
#'
#' This function uses hand-crafted regular expressions to replace certain strings
#' in the given SVG with the values given as arguments.
#'
#' This only really works because the SVG text that the USGS was derived from was
#' relatively regular in layout/naming.
#'
#' @param pattern svg text
#' @param width,height size in pixels
#' @param alpha opacity. default: 1. (opaque)
#' @param fill default: '#ffffff'
#' @param angle angle in degrees
#'
#' @return adjusted svg text
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
modify_usgs_pattern <- function(pattern, width, alpha = 1, fill = '#ffffff',
                                angle = 0, height=width) {

  # Replace attributes in the the <pattern>
  pattern <- sub('width=".*?"' , paste0('width="' , width , '"'), pattern)
  pattern <- sub('height=".*?"', paste0('height="', height, '"'), pattern)

  pattern <- sub('patternTransform=".*?"',
                 glue::glue('patternTransform="rotate({angle} 0 0)"'), pattern)


  # replace attribtutes in the first 'rect' which serves as the background
  replacement <- glue::glue("fill:{fill}; fill-opacity:{alpha}; stroke:none;")
  pattern <- sub('fill:none;', replacement, pattern)

  pattern

}

