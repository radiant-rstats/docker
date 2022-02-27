library(testthat)
if (file.exists("code-solution.R")) {
  source("code-solution.R")
} else {
  source("code-template.R")
}

ps <- optimize_prices(readr::read_rds("data/prices.rds"))


test_that("[Using provided data] Checking Monday's price.", {
  expect_equal(ps[1], 60, tolerance = 1e-1)
})

test_that("[Using provided data] Checking Tuesday's price.", {
  expect_equal(ps[2], 32, tolerance = 1e-1)
})


ps_2 <- optimize_prices(readr::read_rds("data/prices_2.rds"))


test_that("[Using test data #1] Checking Monday's price.", {
  expect_equal(ps_2[1], 56, tolerance = 1e-1)
})

test_that("[Using test data #1] Checking Tuesday's price.", {
  expect_equal(ps_2[2], 38, tolerance = 1e-1)
})


ps_3 <- optimize_prices(readr::read_rds("data/prices_3.rds"))


test_that("[Using test data #2] Checking Monday's price.", {
  expect_equal(ps_3[1], 58, tolerance = 1e-1)
})

test_that("[Using test data #2] Checking Tuesday's price.", {
  expect_equal(ps_3[2], 36, tolerance = 1e-1)
})
