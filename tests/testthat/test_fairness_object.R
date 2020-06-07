
test_that("test fairness object", {


  data <- compas
  data$`_probabilities_` <- explainer_ranger$y_hat



  fobject10 <- create_fairness_object(explainer_ranger,
                                      data = data,
                                      outcome = "Two_yr_Recidivism",
                                      group = "Ethnicity",
                                      base = "Caucasian")

  data_C <- data[data$Ethnicity == "Caucasian",]
  preds01_C <- factor(round(data_C$`_probabilities_`))
  preds10_C <- relevel(preds01_C, "1")

  true01_C <- relevel(data_C$Two_yr_Recidivism, "0")
  true10_C <- relevel(data_C$Two_yr_Recidivism, "1")

  tp_C <- sum(true10_C == preds10_C & true10_C == 1)
  tn_C <- sum(true10_C == preds10_C & true10_C == 0)
  fp_C <- sum(true10_C != preds10_C & true10_C == 0)
  fn_C <- sum(true10_C != preds10_C & true10_C == 1)


  gm <- group_matrices(data, group = "Ethnicity", outcome = "Two_yr_Recidivism", outcome_numeric = explainer_ranger$y, cutoff = rep(0.5,6))

  expect_equal(gm$Caucasian$tp, tp_C)
  expect_equal(gm$Caucasian$fp, fp_C)
  expect_equal(gm$Caucasian$tn, tn_C)
  expect_equal(gm$Caucasian$fn, fn_C)


  data_A <- data[data$Ethnicity == "African_American",]
  preds01_A <- as.factor(round(data_A$`_probabilities_`))
  preds10_A <- relevel(preds01_A, "1")

  true10_A <- relevel(data_A$Two_yr_Recidivism, "1")

  tp_A <- sum(true10_A == preds10_A & true10_A == 1)
  tn_A <- sum(true10_A == preds10_A & true10_A == 0)
  fp_A <- sum(true10_A != preds10_A & true10_A == 0)
  fn_A <- sum(true10_A != preds10_A & true10_A == 1)


  expect_equal(gm$African_American$tp, tp_A)
  expect_equal(gm$African_American$fp, fp_A)
  expect_equal(gm$African_American$tn, tn_A)
  expect_equal(gm$African_American$fn, fn_A)

  # now checking if values in groups are scaled properly
  tpr_C <- tp_C/(tp_C + fn_C)
  tpr_A <- tp_A/(tp_A + fn_A)

  fobject_value <- round(fobject10$groups_data$ranger$TPR[1],3)
  names(fobject_value) <- NULL
  expect_equal(fobject_value, round(tpr_C,3))

  fobject_value <- round(fobject10$groups_data$ranger$TPR[2],3)
  names(fobject_value) <- NULL
  expect_equal(fobject_value, round(tpr_A,3))

  expect_error(create_fairness_object(explainer_ranger,
                                      data = compas,
                                      outcome = "Two_yr_Recidivism",
                                      group = "notindata",
                                      base = "Caucasian"))

  expect_error(create_fairness_object(explainer_ranger,
                                      data = compas,
                                      outcome = "notindata",
                                      group = "Ethnicity",
                                      base = "Caucasian"))

  expect_error(create_fairness_object(explainer_ranger,
                                      data = compas,
                                      outcome = "Two_yr_Recidivism",
                                      group = "Ethnicity",
                                      base = "notidata"))

  expect_error(create_fairness_object(explainer_ranger,
                                      data = compas,
                                      outcome = "Age",
                                      group = "Ethnicity",
                                      base = "notindata"))


  expect_error(create_fairness_object(explainer_ranger,
                                      data = compas,
                                      outcome = "Two_yr_Recidivism",
                                      group = "Ethnicity",
                                      base = "Caucasian",
                                      cutoff = "notnumeric"))


  expect_error(create_fairness_object(explainer_ranger,
                                      data = compas,
                                      outcome = "Two_yr_Recidivism",
                                      group = "Ethnicity",
                                      base = "Caucasian",
                                      cutoff = c(1.3)))

  expect_error(create_fairness_object(explainer_ranger,
                                      data = compas,
                                      outcome = "Two_yr_Recidivism",
                                      group = "Ethnicity",
                                      base = "Caucasian",
                                      cutoff = c(1, 0.3)))


  expect_error(create_fairness_object(explainer_ranger, explainer_ranger,
                                      data = compas,
                                      outcome = "Two_yr_Recidivism",
                                      group = "Ethnicity",
                                      base = "Caucasian"))





  ######################## plot #############################

  plt <- plot(fobject)

  expect_class(plt, "ggplot")

})

