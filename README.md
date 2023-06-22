# NeutraliseFiles
NeutraliseFiles is a repository that includes all results of Neutralise, an open source initiative for neutral comparison of two-sample tests. For more information on Neutralise, we refer to https://github.com/lucp9827/Neutralise. 

[Check the wiki for:](https://github.com/lucp9827/NeutraliseFiles/wiki) 
1. [Details and information on NeutraliseFiles](https://github.com/lucp9827/NeutraliseFiles/wiki)
2. [Policy and maintenance plan](https://github.com/lucp9827/NeutraliseFiles/wiki/Policy)
3. [Yearly summary](https://github.com/lucp9827/NeutraliseFiles/wiki/Yearly-Summary-Report)

   
We provide two step-by-step instructions for NeutraliseFiles: 

### A. Step-by-step instructions - Starting from an empty NeutraliseFiles folder

This concise checklist is intended for users to install Neutralise and start working from the beginning, an
empty NeutraliseFiles folder, and generate their own results. For more details and examples, we refer to
the Demonstration file of Neutralise (https://github.com/lucp9827/Neutralise). We recommend following
this tutorial to understand how the Neutralise function works and what the possibilities are within this
initiative.

1. Download NeutraliseFiles_empty.zip from https://github.com/lucp9827/NeutraliseFiles and unzip this
folder.
2. Start R.
3. Set the working directory of your R-session to the folder NeutraliseFiles in the unzipped NeutraliseFiles_empty folder.

4. Save this working directory also to the object path. (R-code: path=getwd())
   
5. Install Neutralise. You can use the following R-code: remotes::install_github(’lucp9827/Neutralise’)

6. Load Neutralise in your R-session. (R-code: library(Neutralise))

7. Run the function Initialise_Neutralise(path)

8. You can start using the Neutralise function. (check the README file of Neutralise for details on the function
possibilities)


### B. Step-by-Step instructions for Neutralise - Starting from the Github repository NeutraliseFiles
This concise checklist is intended for users to analyze the results from the Github repository NeutraliseFiles. For more details and examples, we refer to the Demonstration file of Neutralise (https://github.com/lucp9827/Neutralise).
We recommend following this tutorial to understand how the Neutralise function works and what the pos-
sibilities are within this initiative.
1. Download NeutraliseFiles_full.zip from https://github.com/lucp9827/NeutraliseFiles and unzip this
folder.
2. Start R.
3. Set the working directory of your R-session to the folder NeutraliseFiles in the unzipped NeutraliseFiles_full folder.
4. Install and load the following packages in your R-session: remotes, dplyr, moments, ggplot2, kSam-
ples, lawstat, BWStest, twosamples, RVAideMemoire, DescTools, WRS2, gk, gld.
``` r
#Rcode to Install load required packages:

reqpkg = c(”remotes”,”dplyr”,”moments”,”ggplot2”,”kSamples”,”lawstat”,”BWStest”, ”RVAideMem-
oire”,”DescTools”,”WRS2”,”gk”,”gld”,”twosamples”);

for(i in reqpkg)
{print(i)
print(packageVersion(i))
install.packages(i)
library(i, quietly=TRUE, verbose=FALSE, warn.conflicts=FALSE, character.only=TRUE)}
```
5. Install Neutralise. You can use the following R-code: remotes::instal github(’lucp9827/Neutralise’)

6. Load Neutralise in your R-session. (R-code: library(Neutralise))

7. You are ready to start analysing the data, we propose two options below. However, if you want to start
from the original result files, check the Demonstration file to understand how the results are organized
in the NeutraliseFiles.

Option 1: You can start analysing the data with the provided visualization functions (power-power plot, type
I error rate boxplots, power curves), check the demonstration file in the Neutralise package for
more details.

Option 2: You can use the summarized .RData files of all the results (type I error rate, power) for your own
code or analysis. The files without _df extension are lists per data generation method and include
all the setting parameters per scenario and the results, while the files with _df extension are data
frames with an id number for the setting and the results (without setting parameters).
