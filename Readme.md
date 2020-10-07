ImportElectionResults

A Microsoft SQL database of election results for 2015 and 2019 and the SSIS package to generate them from raw Elections Canada data.

If all you want is the data, grab the file ElectionResults_WithData.sql and execute it using SQL Server Management Studio. It will create the ElectionResults database and populate it with results from 2015. Examine the view definitions for the views named SummaryResults and PollResults to get started using this database.

To execute the SSIS package:

1. Modify the OLEDB connection manager to point at an empty ElectionResults database (i.e. without table data)
2. Set the package variable "Year" to the election year for the EC files you have downloaded (for 2019 files see https://www.elections.ca/content.aspx?section=res&dir=rep/off/43gedata&document=bypro&lang=e - download the format 2 files for the geography you are interested in.)
3. Configure the Foreach Loop named "Loop EC Files" to enumerate through the files you've downloaded by setting the enumerator configuration to point to the target folder
4. 

There is no need to execute the package if all you're interested in is poll-by-poll data for 2015 and 2019 - that data has already been processed and is embedded in the .SQL file named above.