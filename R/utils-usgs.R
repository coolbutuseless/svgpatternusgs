
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' All valid USGS codes
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"all_usgs_codes"



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Change the size of a pattern
#'
#' @param pattern svg text
#' @param width,height size in pixels
#' @param alpha opacity. default: 1. (opaque)
#' @param fill default: '#ffffff'
#' @param angle angle in degrees
#'
#' @return adjusted svg text
#' @export
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

