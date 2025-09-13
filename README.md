# ashfi4-Susneo-Shiny-MohammadAsfi
# susneo-shiny-ashfi4

## 1. Setup Instructions
Clone this repository:
```bash
git clone https://github.com/ashfi4/susneo-shiny-ashfi4.git
cd susneo-shiny-ashfi4

```markdown
install.packages(c("shiny", "golem", "ggplot2", "dplyr", "lubridate", "viridis", "testthat"))

```r
shiny::runApp("app.R")

- Bash commands render in a **bash block**.  
- R commands render in **R blocks**.  
- Everything looks clean and clear in GitHub.

**2. App Overview**

This is a Shiny dashboard built using the Golem framework.
It demonstrates:

Modular design (R/ folder with modules)

Dynamic filters and interactive plots

Unit testing with testthat

A reproducible workflow for development and deployment

**3. Architecture**

app.R → App entry point (runs the dashboard)

R/ → Golem modules and helper functions

inst/app/www/ → Static assets (CSS, images, JavaScript)# Nothing as of now as static content

data/ → Holds the  dataset(s)

tests/ → Unit tests with testthat

**4. Data**

The example dataset (data/sample_data.csv) contains:

date → transaction dates

type → category labels

value → numeric measure

This dataset is included for demonstration and testing purposes.

**5. Testing**
testthat::test_dir("tests/testthat")
devtools::test()

The GitHub Actions workflow (.github/workflows/ci.yml) automatically checks the app builds and passes tests on each push.
