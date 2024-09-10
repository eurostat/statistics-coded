![experimental](http://ec.europa.eu/eurostat/statistics-explained/images/9/95/Experimental.png)<br />

**Experimental statistics on Household Income, Consumption and Wealth (ICW)**

This repository is intended to store the codes (in _SAS_, _R_ or _Stata_) related to the design and 
dissemination of the different experimental statistics for the project on European households' 
income, consumption and wealth.

**Context**

The European Commission has stressed the need to bring social indicators on a par with macroeconomic 
indicators within the macroeconomic governance. A key part of the strategy is the availability of 
harmonised statistics at EU level covering the distributional aspects of household income, consumption 
and wealth. This comes along also with the recommendations of the Stiglitz-Sen-Fitoussi Commission, 
which have stressed the need for considering income and consumption jointly with wealth and giving more 
prominence to the distribution of these three dimensions.

The initiative by Eurostat on development and production of harmonised Income, Consumption and Wealth 
data as part of the official statistics in the EU is embedded in the reinforcement of social statistics 
and quality of micro data for joint ICW distributions based on the existing surveys. The closure of data 
gaps between micro and macro statistics using harmonised micro data on joint distributions of ICW is our 
reply to the data needs of policy users in the EU. There are two different workflows associated to this 
project, still with a high degree of coordination and collaboration, and they are described in the following. 

**Description**

The first workflow is purely micro-related, aiming at bringing closer the 
different existing surveys and enlightening the **joint distribution of Income, Consumption and Wealth**. 
Different techniques of statistical matching are intended to be applied in order to build a broader 
picture of the budget constraint faced by European households. 
With reproducibility in mind, the codes developed for this part of the project are made available.
Provided that users have requested beforehand the access to the disseminated micro-data 
(both [EU-SILC and HBS](http://ec.europa.eu/eurostat/web/microdata/overview), 
and [HFCS](https://www.ecb.europa.eu/pub/economic-research/research-networks/html/researcher_hfcn.en.html)),
users the possibility to re-use and reproduce the exercise on these micro-data. 
For the sake of transparency, it provides further insights in the concrete implementation 
of the statistical techniques used for the estimation of the different indicators designed within 
the project. 
Last, using the material provided by Lahti _et al._ (see references [below](#References)), it also 
gives the users the possibility to generate the figures produced for the different 
articles related to the project.

The second workflow aims at building bridges between macro and micro-statistics regarding Income, Consumption 
and Wealth. Similarly to the work carried out by several organisations (OECD, ECB,...), the purpose is to 
reconcile concepts from macro and micro-statistics and produce meso-data that will be consistent at the micro 
and the macro-level.

**Material**

This repository is organised into different folders, each of them corresponding to a part of this project. 
In particular, different Statistics Explained articles have been published in order to tackle the different 
analytical and methodological issues such statistics raise. Hence, some of the folders contain pieces of 
script that make it possible to generate the figures shown in the different articles, namely:
* the script [**icw1.R**](icw1.R) for the graphs in the analytical article on [the interaction of household income, consumption and wealth](http://ec.europa.eu/eurostat/statistics-explained/index.php?title=Interaction_of_household_income,_consumption_and_wealth_-_statistics_on_main_results);
* the script [**icw2.R**](icw2.R) for the graphs in the background paper on [the methodological issues](http://ec.europa.eu/eurostat/statistics-explained/index.php/Interaction_of_household_income,_consumption_and_wealth_-_methodological_issues);
* the script [**icw3.R**](icw3.R) (together with the _country_order.csv_ file in folder [data/](data/)) for the graphs in the analytical article on [the statistics on taxation](http://ec.europa.eu/eurostat/statistics-explained/index.php/Interaction_of_household_income,_consumption_and_wealth_%E2%80%93_statistics_on_taxation).

In addition, code is also made available for the computation of VAT paid by the households 
of the structure of their consumption, according to the COICOP in the Household Budget Survey (see note
[below](#VAT)):
* the script [**rates.R**](rates.R) computes tax rates (see also files _listCOICOP_withRATE.xls_ and _vat_rates_en.xls_ 
 in folder _data/_);
* the script [**vat.R**](rates.R) estimates VAT paid by the households represented in the micro-data (this shall be run
 after the previous script).

**<a name="VAT"></a>Note on the VAT paid by the households**

Analysing the effect of VAT across groups of households requires not only to measure consumption and its 
composition at the household level, but also to have detailed pieces of information regarding the VAT rate
applied according to the type of purchased good.

On the one hand, the classification commonly used to describe households' consumption for the European 
Household Budget Survey is the Classification of Individual Consumption According to Purpose 
([COICOP](https://unstats.un.org/unsd/cr/registry/regcst.asp?Cl=5)). 
On the other hand, the [European Commission's Directorate-General for Taxation and Customs Union](https://ec.europa.eu/taxation_customs/home_en) disseminates some harmonised data on VAT tax rates in the European Union. 
The principle of the exercise is therefore to perform a mapping between the different classifications 
so as to come up with an estimation of the tax rate applied to the products that households declare 
having purchased in the Household Budget Survey. The scripts made available in this repository perform  
such a mapping.

**<a name="References"></a>References**

* Commission on the Measurement of Economic Performance and Social Progress (2008): 
[**Final report**](https://ec.europa.eu/eurostat/documents/118025/118123/Fitoussi+Commission+report).

* Lahti L., Huovari J., Kainu M., and Biecek, P. (2017): 
[**Retrieval and analysis of Eurostat open data with the eurostat package**](https://journal.r-project.org/archive/2017/RJ-2017-019/RJ-2017-019.pdf), _The R Journal_, 9(1):385-392.

**Contact** 

[ESTAT-ICW@ec.europa.eu](mailto:ESTAT-ICW@ec.europa.eu)
