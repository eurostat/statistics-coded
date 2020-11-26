statistics-coded
====================

 Resources for reproducing some of the visualisations in _Eurostat_ Statistics Explained articles.
---

The material provided herein can be used to (re)produce some of the statistical outputs (tables and figures) presented in _Eurostat_ [**Statistics Explained**](https://ec.europa.eu/eurostat/statistics-explained/index.php/Main_Page) articles. it is used to recreate the figures published in the articles and are made available in the form of either code source files or computing notebooks. The latter will allow you to fetch the open data disseminated on _Eurostat_ online database and interact with it dynamically.


<table align="center">
<tr> <td align="left" valign="middle">
    <a href="https://ec.europa.eu/eurostat/statistics-explained/index.php?title=General and regional statistics/EU policies"><img src="https://ec.europa.eu/eurostat/statistics-explained/skins/statexpflat/css/statexpflat/themes/32x32/color/general.png"></a>General and regional statistics / EU policies</td> 
    <td align="left" valign="middle">
    <a href="https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Economy and finance"><img src="https://ec.europa.eu/eurostat/statistics-explained/skins/statexpflat/css/statexpflat/themes/32x32/color/economy.png"></a><a href="economy">Economy and finance</a></td> 
    <td align="left" valign="middle">
    <a href="https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Population and social conditions"><img src="https://ec.europa.eu/eurostat/statistics-explained/skins/statexpflat/css/statexpflat/themes/32x32/color/population.png"></a><a href="popul">Population and social conditions</a></td> 
 </tr> 
<tr> <td align="left" valign="middle">
    <a href="https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Industry and services"><img src="https://ec.europa.eu/eurostat/statistics-explained/skins/statexpflat/css/statexpflat/themes/32x32/color/industry.png"></a><a href="icts">Industry and services</a></td> 
    <td align="left" valign="middle">
    <a href="https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Agriculture, forestry and fisheries"><img src="https://ec.europa.eu/eurostat/statistics-explained/skins/statexpflat/css/statexpflat/themes/32x32/color/agriculture.png"></a>Agriculture, forestry and fisheries</td> 
    <td align="left" valign="middle">
    <a href="https://ec.europa.eu/eurostat/statistics-explained/index.php?title=International trade"><img src="https://ec.europa.eu/eurostat/statistics-explained/skins/statexpflat/css/statexpflat/themes/32x32/color/international.png"></a><a href="external">International trade</a></td> 
 </tr> 
<tr> <td align="left" valign="middle">
    <a href="https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Transport"><img src="https://ec.europa.eu/eurostat/statistics-explained/skins/statexpflat/css/statexpflat/themes/32x32/color/transport.png"></a>Transport</td> 
    <td align="left" valign="middle">
    <a href="https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Environment and energy"><img src="https://ec.europa.eu/eurostat/statistics-explained/skins/statexpflat/css/statexpflat/themes/32x32/color/environment.png"></a><a href="envir">Environment and energy</a></td> 
    <td align="left" valign="middle">
    <a href="https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Science, technology and digital society"><img src="https://ec.europa.eu/eurostat/statistics-explained/skins/statexpflat/css/statexpflat/themes/32x32/color/science.png"></a><a href="science">Science, technology and digital society</a></td> 
 </tr> 
</table>  

**<a name="Quick-launch"></a>Quick launch**

 * **Run the notebooks (both `R` and `Python`) in [`binder`](https://mybinder.org/)**. We provide the interactive environments with already installed packages to query and access _Eurostat_ database for notebook resources below (current build with commit [4d11277](https://github.com/eurostat/statistics-coded/commit/4d11277afeaf631217cb3cd5b022b7ddb6269de9)): <!-- generate new badges: https://mybinder.readthedocs.io/en/latest/howto/badges.html -->
    * Launch [`Jupyter`](https://jupyter.org/) alone:  [![badge](https://img.shields.io/badge/Eurostat%20code-binder-579ACA.svg?logo=data:image/png;base64,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)](https://mybinder.org/v2/gh/eurostat/statistics-coded/4d11277afeaf631217cb3cd5b022b7ddb6269de9?filepath=index.ipynb ) <!-- [![Binder](https://mybinder.org/badge_logo.svg)](http://mybinder.org/v2/gh/eurostat/statistics-coded/master)--> <!-- [![Binder](https://mybinder.org/badge_logo.svg)](http://mybinder.org/v2/gh/eurostat/statistics-coded/master?filepath=index.ipynb)-->
    * Launch [`JupyterLab`](https://jupyterlab.readthedocs.io/): [![badge](https://img.shields.io/badge/Eurostat%20code-binder-579ACA.svg?logo=data:image/png;base64,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)](https://mybinder.org/v2/gh/eurostat/statistics-coded/4d11277afeaf631217cb3cd5b022b7ddb6269de9?urlpath=lab) <!-- [![Binder](https://mybinder.org/badge_logo.svg)](http://mybinder.org/v2/gh/eurostat/statistics-coded/master?urlpath=lab) -->
    * Launch [`RStudio`](https://rstudio.com/):  [![badge](https://img.shields.io/badge/Eurostat%20code-binder-579ACA.svg?logo=data:image/png;base64,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)](https://mybinder.org/v2/gh/eurostat/statistics-coded/4d11277afeaf631217cb3cd5b022b7ddb6269de9?urlpath=rstudio) <!-- [![Binder](https://mybinder.org/badge_logo.svg)](http://mybinder.org/v2/gh/eurostat/statistics-coded/master?urlpath=rstudio) -->
* **Run the notebooks in [`Google colab`](https://colab.research.google.com/)** (you will need a _Google_ login): launch [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/eurostat/statistics-coded/blob/master/) (try for instance **[this notebook](https://colab.research.google.com/github/eurostat/statistics-coded/blob/master/economy/balance-payments/trade-investment-employment-globalisation_py.ipynb)**).
 
**Description**

The resources are organised according to the thematic structure already adopted for the Statistics Explained articles:

* [general/](general) for reproducing some of the Stastistics Explained articles on [_"General and regional statistics, EU policies"_](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=General_and_regional_statistics,_EU_policies),

* [**economy/**](economy) for [_"Economy and finance"_](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Economy_and_finance) articles:
  - [`Python` notebook](economy/balance-payments/trade-investment-employment-globalisation_py.ipynb) on 
  [**trade, investment and employment as aspects of globalisation**](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Trade,_investment_and_employment_as_aspects_of_globalisation),
  - [`Python` notebook](economy/comparative-price-levels/comparative-price-consumer-goods-services_py.ipynb) on 
  [**comparative price levels of consumer goods and services**](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Comparative_price_levels_of_consumer_goods_and_services),
  - ...  
  
* [**popul/**](popul) for [_"Population and social conditions"_](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Population_and_social_conditions) articles:
  - [`JavaScript` notebook](https://observablehq.com/@joewdavies/health-statistics-regional-level_js) on [**health statistics at regional level**](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Health_statistics_at_regional_level),
  - [`R` notebook](https://nbviewer.jupyter.org/github/eurostat/statistics-coded/blob/master/popul/health/causes-death-statistics_r.ipynb) on [**causes of death statistics**](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Causes_of_death_statistics),
  - [`Python` notebook](https://nbviewer.jupyter.org/github/eurostat/statistics-coded/blob/master/popul/labour-market/hours-work-quarterly-statistics_py.ipynb) on [**hours of work**](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Hours_of_work_-_quarterly_statistics),
  - [`R` notebook](https://nbviewer.jupyter.org/github/eurostat/statistics-coded/blob/master/popul/population/population-structure-ageing_r.ipynb) on [**population structure and ageing**](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Young_people_-_social_inclusion),
  - [`R` notebook](https://nbviewer.jupyter.org/github/eurostat/statistics-coded/blob/master/popul/population/young-people-social-inclusion_r.ipynb) on [**young people and social inclusion**](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Young_people_-_social_inclusion),
  - [`Python` notebook](https://nbviewer.jupyter.org/github/eurostat/statistics-coded/blob/master/popul/living-conditions/living-conditions-poverty-social-exclusion_py.ipynb) on [**poverty and social exclusion**](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Living_conditions_in_Europe_-_poverty_and_social_exclusion),
  - [`Python` notebook](https://nbviewer.jupyter.org/github/eurostat/mortality-viz/blob/master/02_mortality_european_regions.ipynb) on [**weekly death statistics**](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Weekly_death_statistics&stable),
  - [`R` source code](https://nbviewer.jupyter.org/github/eurostat/statistics-coded/blob/master/popul/living-conditions/income-consumption-wealth_r) for [**income, consumption and wealth**](https://ec.europa.eu/eurostat/web/experimental-statistics/income-consumption-and-wealth),
  - ...  
  
* [**icts/**](icts) for [_"Industry and services"_](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Industry_and_services) articles:
  - [`R` notebook](https://nbviewer.jupyter.org/github/eurostat/statistics-coded/blob/master/icts/tourism/tourism-statistics_r.ipynb) on [**tourism statistics**](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Tourism_statistics),
  - [`SQL` source code](icts/business-registers/multinational-enterprise-groups_sql) for [**structure of multinational enterprise groups in the EU**](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Structure_of_multinational_enterprise_groups_in_the_EU),
  - ... 
  
* [agric/](agric) for [_"Agriculture, forestry and fisheries"_](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Agriculture,_forestry_and_fisheries) articles,

* [**external/**](external) for [_"International trade"_](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=International_trade) articles:
  - [`R` notebook](https://nbviewer.jupyter.org/github/eurostat/statistics-coded/blob/master/external/services/eu-international-trade-transport-services_r.ipynb) on [**EU international trade in transport services**](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=EU_international_trade_in_transport_services),
  - ...  

* [transp/](transp) for [_"Transport"_](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Transport),

* [**envir/**](envir) for [_"Environment and energy"_](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Environment_and_energy) articles:
  - [`Python` notebook](https://nbviewer.jupyter.org/github/eurostat/statistics-coded/blob/master/envir/environment/environmental-economy-employment-growth_py.ipynb) on [**employment and growth statistics**](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Environmental_economy_–_statistics_on_employment_and_growth#Development_of_key_indicators_for_the_environmental_economy),
  - ...

* [**science**/](science) for [_"Science, technology and digital society"_](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Science,_technology_and_digital_society) articles:
  - [`R` notebook](https://nbviewer.jupyter.org/github/eurostat/statistics-coded/blob/master/science/digital-economy-society/social-media-use-by-enterprises-statistics_py.ipynb) on [**social media use by enterprises**](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Social_media_-_statistics_on_the_use_by_enterprises),
  - [`R` demo notebook](https://nbviewer.jupyter.org/github/eurostat/statistics-coded/blob/master/science/digital-economy-society/digital-economy-society-households-individuals_r-demo.ipynb) for [**Digital economy and society statistics - households and individuals**](https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Digital_economy_and_society_statistics_-_households_and_individuals),
  - ...    
  
**<a name="About"></a>About**

Want to contribute? For instance, implement a *Statistics Explained* article you find very interesting in your favourite language? Please submit your [pull requests](https://github.com/eurostat/statistics-coded/pulls) directly to the _master_ branch!

Found a mistake in the code? Please, report it to us in the [issues section](https://github.com/eurostat/statistics-coded/issues).

<table align="center">
    <tr> <td align="left"><i>contributors</i></td> 
    <td align="left" valign="middle">
<a href="https://github.com/fmshka"><img src="https://github.com/fmshka.png" width="40"></a>
<a href="https://github.com/Dgojsic"><img src="https://github.com/Dgojsic.png" width="40"></a>
<a href="https://github.com/beatrizq"><img src="https://github.com/beatrizq.png" width="40"></a>
<a href="https://github.com/ericofrs"><img src="https://github.com/ericofrs.png" width="40"></a>
<a href="https://github.com/IsabellaMarinetti"><img src="https://github.com/IsabellaMarinetti.png" width="40"></a>
<a href="https://github.com/kkatha"><img src="https://github.com/kkatha.png" width="40"></a>
<a href="https://github.com/LasaiBarrenada"><img src="https://github.com/LasaiBarrenada.png" width="40"></a>
<a href="https://github.com/LBonamino"><img src="https://github.com/LBonamino.png" width="40"></a>
<a href="https://github.com/mattiagirardi"><img src="https://github.com/mattiagirardi.png" width="40"></a>
<a href="https://github.com/rderayati"><img src="https://github.com/rderayati.png" width="40"></a>
<a href="https://github.com/sarah2397"><img src="https://github.com/sarah2397.png" width="40"></a>
<a href="https://github.com/agnebik"><img src="https://github.com/agnebik.png" width="40"></a>
<a href="https://github.com/flopaleur"><img src="https://github.com/flopaleur.png" width="40"></a>
<a href="https://github.com/flopaleur"><img src="https://github.com/JoeWDavies.png" width="40"></a>
<a href="https://github.com/pierre-lamarche"><img src="https://github.com/pierre-lamarche.png" width="40"></a>
<a href="https://github.com/mmatyi"><img src="https://github.com/mmatyi.png" width="40"></a>
<a href="https://github.com/gjacopo"><img src="https://github.com/gjacopo.png" width="40"></a>
</td>  </tr> 
    <tr> <td align="left"><i>version</i></td> <td align="left">0.1</td> </tr> 
    <tr> <td align="left"><i>status</i></td> <td align="left">since 2019</td> </tr> 
    <tr> <td align="left"><i>license</i></td> <td align="left"><a href="https://joinup.ec.europa.eu/sites/default/files/eupl1.1.-licence-en_0.pdfEUPL">EUPL</a> <i></i></td> </tr> 
</table>

**<a name="Resources"></a>Resources**

* _Eurostat_ [**online database**](https://ec.europa.eu/eurostat/data/database).
* **Statistics Explained** [main page](https://ec.europa.eu/eurostat/statistics-explained/index.php/Main_Page).
* `R` packages to access open data: [`restatapi`](https://github.com/eurostat/restatapi), [`rsdmx`](https://github.com/opensdmx/rsdmx) (via _SDMX_), [`eurostat`](http://ropengov.github.io/eurostat), [`rjstat`](https://github.com/ajschumacher/rjstat) (via _JSON-stat_).
* `Python` modules to access open data: [`pandaSDMX`](https://github.com/dr-leo/pandaSDMX) (via _SDMX_), [`jsonstat.py`](https://github.com/26fe/jsonstat.py), [`eurostatapiclient`](https://github.com/opus-42/eurostat-api-client), [`pyrostat`](https://github.com/eurostat/pyrostat.py) (via _JSON-stat_).
* [More](https://json-stat.org/tools/) on _JSON-stat_ format and tools.
* Useful graphic tools galleries, in [`R`](https://www.r-graph-gallery.com/) and [`Python`](https://python-graph-gallery.com/).
* `binder` [documentation](https://mybinder.readthedocs.io/en/latest/) and [examples](https://github.com/binder-examples).
* `repo2docker` [configuration files](https://repo2docker.readthedocs.io/en/latest/config_files.html).
* BBC visual and data journalism [**cookbook for `R` graphics**](https://bbc.github.io/rcookbook/).
* World Bank [atlas of Sustainable Development Goals 2018](http://datatopics.worldbank.org/sdgatlas/) with the [source code](https://github.com/worldbank/sdgatlas2018). 

**<a name="References"></a>References**

* [**How Open Are Official Statistics?**](http://opendatawatch.com/monitoring-reporting/how-open-are-official-statistics/).
* Luhmann S., Grazzini J., Ricciato F., Meszaros M., Giannakouris K., Museux J.-M. and Hahn M. (2019): [**Promoting reproducibility-by-design in statistical offices**](https://www.researchgate.net/publication/332045930_Promoting_reproducibility-by-design_in_statistical_offices), in Proc. _New Techniques and Technologies for Statistics_, doi:[10.5281/zenodo.3240198](https://dx.doi.org/10.5281/zenodo.3240198).
* Grazzini J., Gaffuri J. and Museux J.-M. (2019): [**Delivering Official Statistics as Do-It-Yourself services to foster produsers' engagement with Eurostat open data**](https://www.researchgate.net/publication/332079417_Delivering_Official_Statistics_as_Do-It-Yourself_services_to_foster_produsers%27_engagement_with_Eurostat_open_data) in Proc. _New Techniques and Technologies for Statistics_, doi:[10.5281/zenodo.3240272](https://dx.doi.org/10.5281/zenodo.3240272).
* Project Jupyter _et al._ (2018): [**Binder 2.0 - Reproducible, interactive, sharable environments for science at scale**](https://conference.scipy.org/proceedings/scipy2018/pdfs/project_jupyter.pdf), in Proc. _Python in Science Conference_, doi:[10.25080/Majora-4af1f417-011](https://dx.doi.org/10.25080/Majora-4af1f417-011).
* Grazzini J., Museux J.-M. and Hahn M. (2018): [**Empowering and interacting with statistical produsers: A practical example with Eurostat data as a service**](https://www.researchgate.net/publication/325973362_Empowering_and_interacting_with_statistical_produsers_a_practical_example_with_Eurostat_data_as_a_service), in Proc. _Conference of European Statistics Stakeholders_, doi:[10.5281/zenodo.3240557](https://dx.doi.org/10.5281/zenodo.3240557).
* Lahti L., Huovari J., Kainu M. and Biecek, P. (2017): [**Retrieval and analysis of Eurostat open data with the eurostat package**](https://journal.r-project.org/archive/2017/RJ-2017-019/RJ-2017-019.pdf), _The R Journal_, 9(1):385-392.
