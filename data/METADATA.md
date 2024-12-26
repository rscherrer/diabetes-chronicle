The database is called `diabetes_2024.ods`. 

Here I describe the content of the database. For details, see the accompanying [manuscript](https://github.com/rscherrer/diabetes-chronicle-ms).

The main sheet contains the `Data`. Each row is a timed event with its associated details.

## Main columns

* `Date`
* `Time`
* `Event Type`: either of `Glycemia`, `Activity`, `Food`, `Insulin`, `Insulin Slow`, `Note` or `Missing`

Then, different columns are relevant based on `Event Type`.

### Glycemia

* `Blood Sugar`: the recorded glycemia (in mg/dL)
* `Glycemia Slope`, as recorded by the sensor (`Crashing`, `Decreasing`, `Stagnating`, `Increasing`, `Spiking`)

### Food

* `Food Glucose`: the amount of carbohydrates eaten (in grams)
* `Food Type`: the food item (e.g. chocolate, bread, etc.)
* `Food Glucose Precision`, as perceived by me (`Low`, `Medium` or `High`)
* `Alcohol Content` of the food item (in centiliters)
* `Inebriation Status` from alcohol use (ranging from 0 to 4)

### Insulin

* `Insulin Dose`: the insulin injected, in units
* `Insulin Cartridge`: an identifier to be able to tell every time I started a new cartridge

### Insulin Slow

* `Slow Insulin Dose`, in units

### Activity

* `Activity Type` (e.g. bike, run, etc.)
* `Activity Duration` (in minutes)
* `Activity Intensity`, or physical effort (`Light`, `Moderate` or `Intense`)
* `Activity Impact Score` as subjectively perceived because intensity does not really reflect how taxing a given activity is for blood sugar (from 0 to 4)

## Extra columns

Other colums include:

* `Slow Insulin Cover` (`Yes`, `Likely` when I did not write it down but was pretty sure it was a yes, or `No`): whether I was under the influence of slow insulin at that time
* `Sick` (`Yes` or `No`): whether I had some kind of infection
* `Wake Period`: which "day" I was in, with day being a continued period of activity

## Chunks of time

Finally, I created three sets of three columns each, to record "chunks" of time for which to base the rest of the analysis (thus counting chunks as the basis of observation when calculating total glucose and insulin input).

Each set was based on a different time threshold: **1.5 hours**, **2 hours** or **3 hours**. This time threshold represented how much time had to had passed without an injection of insulin or a food intake, for a (stagnating) glycemia to be considered a *key glycemia*, that is, a glycemia susceptible to act as beginning or end of a chunk of time. (Note that for 2hr I actually counted more-or-less 10min and for 3hr more-or-less 15min.) 

This way of identifying separate chunks was an attempt at identifying time periods more-or-less independent from the events that happened before them (thus 3 hours gives the highest confidence that chunks are independent, but also the fewest data points).

Chunks were then identified as spans of time between any two consecutive key glycemias, and written as `a` and `b` symbols, with `a` standing for "within a given chunk", and `b` marking the end of that chunk --- just a trick to make the automated analysis easier down the line. This was done in two separate columns, `Chunk <...> A` and `Chunk <...> B` (where `<...>` stands for the time threshold, `1.5`, `2` or `3`), again to be able to easily tell apart consecutive chunks.

To sum up, the chunk-related columns are:

* `Key <...>`: whether a given glycemia is a key glycemia (stagnating and more than `<...>` hours after the last insulin or food)
* `Chunk <...> A` and `Chunk <...> B`: the two columns with `a` and `b` symbols identifying the start and end of each chunk.

Note that chunks containing a `Missing` entry in column `Event Type` were dismissed.

## Other sheets

The two extra sheets in `diabetes_2024.ods` contain, respectively, the `Carb Content` and `Alcohol Content` information used in this analysis as reference to calculate amounts of glucose (in grams) and alcohol (in percentage of volume) ingested, respectively, for common and recurring food items.

## Other files

All the other data files in this folder are produced by the scripts in the `../scripts` folder, and are inputs or outputs of the analysis. For details, please refer to the manuscript or the commenst in the scripts that produced them, but for now, in short:

* `diabetes_2024.csv` is the analysis-friendly, CSV version of the first sheet of the database `diabetes_2024.ods`
* `injection_table.csv` is the final table giving a guide for how much insulin to inject (in units) per carbohydrate intake (column `Glucose`, in grams) and per desired change in glycemia (header row, in mg/dL)
* `chunks/` contains analyzable data sets on a per time chunk basis, produced by summarizing the information within each chunk from the main database, each one for its respective time threshold
* `parameters/` contains tables summarizing the regression parameters (slopes and intercepts) measured from the chunk data, for different states (`normal`, `activity`, `alcohol` and `sick`), and with extra conversion parameters (`Alpha` and `Beta`) as described in the manuscript

