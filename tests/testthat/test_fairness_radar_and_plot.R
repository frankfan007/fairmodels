test_that("Test_fairness_radar_and_plot", {

  fradar <- fairness_radar(fobject)

  expect_equal(fradar$n, length(fobject$explainers))

  metrics <- fobject$metric_data
  models  <- fobject$labels

  for (metric in unique_metrics()){
    for (model in models){
      actual <- fobject$metric_data[fobject$labels == model, metric]
      to_check <- as.character(fradar$df$metric) == metric & as.character(fradar$df$model) == model
      expect_equal(fradar$df[to_check,"score"], actual)
    }
  }

  expect_error(fairness_radar(fobject, fairness_metrics = 1))
  fo <- fobject
  fo$metric_data[2,2] <- NA

  expect_warning(fairness_radar(fo))

  fo$metric_data[2,1:10] <- NA

  expect_error(fairness_radar(fo))

  ############### plot #######################
  plt       <- plot(fradar)
  crd_radar <- coord_radar()

  # checking if plot data is equal to df scaled by max val
  expect_equal(plt$data$score, fradar$df$score/max(fradar$df$score))
  expect_class(crd_radar, "CordRadar")

  expect_class(plt, "ggplot")

  ggproto("CordRadar", CoordPolar, theta = "x", r = "y", start = - pi / 3,
          direction = 1, is_linear = function() TRUE, render_bg = render_bg_function)

  expect_error(render_bg_function())
  expect_error(theta_rescale())


})