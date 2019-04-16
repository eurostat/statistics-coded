statistics-coded
====================

 Resources for reproducing the outputs of _Eurostat_ Stastistics Explained articles.
---

**About**

The code source files provided herein can be used to (re)produce some of the statistical results presented in _Eurostat_ [**Statistics Explained**](https://ec.europa.eu/eurostat/statistics-explained/index.php/Main_Page) articles. For some articles, the published figures can be directly generated using the open data disseminated on _Eurostat_ online database by running the available interactive computing notebooks.

<table align="center">
    <tr> <td align="left"><i>contributors</i></td> 
    <td align="left" valign="middle">
<a href="https://github.com/agnebik"><img src="https://github.com/agnebik.png" width="40"></a>
<a href="https://github.com/gjacopo"><img src="https://github.com/gjacopo.png" width="40"></a>
</td>  </tr> 
    <tr> <td align="left"><i>version</i></td> <td align="left">0.1</td> </tr> 
    <tr> <td align="left"><i>since</i></td> <td align="left">2019</td> </tr> 
    <tr> <td align="left"><i>license</i></td> <td align="left"><a href="https://joinup.ec.europa.eu/sites/default/files/eupl1.1.-licence-en_0.pdfEUPL">EUPL</a> <i></i></td> </tr> 
</table>

**Description**

The notebooks are organised according to the thematic structure already adopted for the Stastistics Explained articles:

* [general/](general) for reproducing some of the Stastistics Explained articles on [_"General and regional statistics, EU policies"_](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=General_and_regional_statistics,_EU_policies),
* [economy/](economy) for [_"Economy and finance"_](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Economy_and_finance) articles,
* [**popul/**](popul) for [_"Population and social conditions"_](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Population_and_social_conditions) articles:

  * [notebook](https://github.com/eurostat/statistics-coded/blob/master/popul/young-people-social-inclusion_R.ipynb) on [Young people - social inclusion](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Young_people_-_social_inclusion),
  * ...
* [**icts/**](icts) for [_"Industry and services"_](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Industry_and_services) articles:

  * [source code](https://github.com/eurostat/statistics-coded/tree/master/icts/multinational_enterprise_groups_SQL) for [structure of multinational enterprise groups in the EU](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Structure_of_multinational_enterprise_groups_in_the_EU),
  * ...
* [agric/](agric) for [_"Agriculture, forestry and fisheries"_](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Agriculture,_forestry_and_fisheries) articles,
* [external/](external) for [_"International trade"_](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=International_trade) articles,
* [transp/](transp) for [_"Transport"_](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Transport),
* [envir/](envir) for [_"Environment and energy"_](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Environment_and_energy) articles,
* [science/](science) for [_"Science, technology and digital society"_](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Science,_technology_and_digital_society) articles.

**<a name="References"></a>Tools and references**

* **Statistical Explained** [main page](https://ec.europa.eu/eurostat/statistics-explained/index.php/Main_Page).
* [**How Open Are Official Statistics?**](http://opendatawatch.com/monitoring-reporting/how-open-are-official-statistics/).
* Lahti L., Huovari J., Kainu M., and Biecek, P. (2017): [**Retrieval and analysis of Eurostat open data with the eurostat package**](https://journal.r-project.org/archive/2017/RJ-2017-019/RJ-2017-019.pdf), _The R Journal_, 9(1):385-392.
* [**BBC Visual and Data Journalism cookbook for R graphics**](https://bbc.github.io/rcookbook/).
* Package [_restatapi_ `R`](https://github.com/eurostat/restatapi) to access open data from Eurostat via _SDMX_.
* Package [_eurostat_ `R`](http://ropengov.github.io/eurostat) to access open data from Eurostat.
* Useful graphic tools galleries, in [_R_](https://www.r-graph-gallery.com/) and [_Python_](https://python-graph-gallery.com/).

