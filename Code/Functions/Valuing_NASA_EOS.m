%% Giving value to each of the EOS satellites



function eos = Valuing_NASA_EOS (eos)

%% The most simplest form of valuing
% 
% for u=1:length(eos)
%     application_score = length(eos(u).applications);
%     science_score = length(eos(u).science);
%     Instrument_score = eos(u).no_instruments;
%     cost_score = eos(u).cost/100;
%     eos(u).value = application_score+science_score+Instrument_score+cost_score;
% end

%% VALUING EACH SCIENCE APPLICATION (based on 2021)
% GDP data taken from The World Bank at https://data.worldbank.org/indicator/NY.GDP.MKTP.CD?locations=US
% USD from 2020 is converted to December 2021 in CPI inflation calculator at https://data.bls.gov/cgi-bin/cpicalc.pl?cost1=1.00&year1=202012&year2=202112
usd2020to2021=1.07;
TUSD=1e12; % Trillion US dollars [USD]
BUSD=1e9; % Billion US dollars [USD]
GDP2020=20.89*TUSD; % [USD]
GDP2021=23*TUSD; % [USD]

%% Agriculture
% Data taken from https://www.ers.usda.gov/data-products/ag-and-food-statistics-charting-the-essentials/ag-and-food-sectors-and-the-economy/
% Data matches with world bank at https://data.worldbank.org/indicator/NV.AGR.TOTL.ZS?locations=US
%AgricultureGDP2020=0.011*GDP2020; % Including all food services related
%FarmGDP2020=134.7*1e9;
AgricultureGDP2021=1.264*TUSD;
FarmToTextileMan=560*BUSD;
%FarmGDP2021=FarmGDP2020*usd2020to2021;
score_agriculture=AgricultureGDP2021/TUSD;

%% Air Quality
% Inspiration by "Fine particulate matter damages and value added in the US economy", 2019 Paper
% New results used by "Environmental performance index" , Carnegie Mellon University at: https://esgindex.cmu.edu/
% GED without Greenhouse gases
GEDtoGDPpercentage2021=mean([0.03696 0.03212 0.0490 0.02792]);
GED2021=GEDtoGDPpercentage2021*GDP2021; % [USD]
score_airquality=GED2021/TUSD;

%% Aviation
% Data taken from 2020 FAA report "The Economic Impact of Civil Aviation on the U.S. Economy" corresponding to 2016
aviation_gdp_percentage2016=2.3/100;
aviation_economic_value2021=aviation_gdp_percentage2016*GDP2021;
score_aviation=aviation_economic_value2021/TUSD;

%% Carbon management
% Basically effects of CO2 as GED from https://esgindex.cmu.edu/
CO2toGDPpercentage2021=mean([0.01410 0.01392 0.01391 0.01370]);
CO22021=CO2toGDPpercentage2021*GDP2021;
score_carbon=CO22021/TUSD;

%% Coastal management
% Coastal erosion damages and costs taken at https://toolkit.climate.gov/topics/coastal-flood-risk/coastal-erosion
% Not a good scoring method
coast_erosion=(500+150)*1e6; %[USD]
score_coast=coast_erosion/TUSD;

%% Disaster management
% Disaster overall damages/costs for 2021 taken from https://www.ncei.noaa.gov/access/billions/
disasters_cost=152.6*1e9;
score_disaster=disasters_cost/TUSD;

%% Energy management
% total Energy expenditure 2020 per state taken from https://www.eia.gov/state/seds/sep_sum/html/pdf/rank_pr.pdf
energy_gdp_percentage2020=4.82/100;
energy_expenditure2020=energy_gdp_percentage2020*GDP2020;
score_energy=energy_expenditure2020*usd2020to2021/TUSD;

%% Homeland security
% Annual budget of Department of Homeland Security year 2021 taken from https://www.usaspending.gov/agency/department-of-homeland-security?fy=2021
homeland_security2021=197.91*1e9;
score_security=homeland_security2021/TUSD;

%% Invasive species
% Mean annual costs taken from "Economic costs of biological invasions in the United States" 2020
Invasive_costs=21.08*1e9;
score_invasive=Invasive_costs/TUSD;

%% Public health
% Health expenditure 2019 US percentage from GDP taken from https://data.worldbank.org/indicator/SH.XPD.CHEX.GD.ZS?locations=US
% Percentage of GDP in 2020 (After COVID) taken from CMS at https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/NationalHealthExpendData/NationalHealthAccountsHistorical
health_gdp_percentage2019=16.8/100;
health_gdp_percentage2020=19.7/100;
health_cost2021=GDP2020*health_gdp_percentage2020*usd2020to2021;
score_health=health_cost2021/TUSD;

%% Water management
% Estimated percentage for Total water management and accessibility estimated for 2030 taken at "ACHIEVING ABUNDANCE: UNDERSTANDING THE COST OF A SUSTAINABLE WATER FUTURE"
water_management_percentage=0.8/100;
water_costs=water_management_percentage*GDP2021;
score_water=water_costs/TUSD;


%% VALUING THE SATELLITE (No primary instrument or secondary instrument discrimination)
for u=1:length(eos)
    value=0;
    if any(strcmp(eos(u).applications,"Agricultural Efficiency")); value=value+score_agriculture; end
    if any(strcmp(eos(u).applications,"Air Quality")); value=value+score_airquality; end
    if any(strcmp(eos(u).applications,"Aviation")); value=value+score_aviation; end
    if any(strcmp(eos(u).applications,"Carbon Management")); value=value+score_carbon; end
    if any(strcmp(eos(u).applications,"Coastal Management")); value=value+score_coast; end
    if any(strcmp(eos(u).applications,"Disaster Management")); value=value+score_disaster; end
    if any(strcmp(eos(u).applications,"Energy Management")); value=value+score_energy; end
    if any(strcmp(eos(u).applications,"Homeland Security")); value=value+score_security; end
    if any(strcmp(eos(u).applications,"Invasive Species")); value=value+score_invasive; end
    if any(strcmp(eos(u).applications,"Public Health")); value=value+score_health; end
    if any(strcmp(eos(u).applications,"Water Management")); value=value+score_water; end
    %%LEAVING A PART HERE FOR MAIN, SECONDARY, REST TYPE OF APPLICATIONS, WILL ADD VALUE
    score_cost = eos(u).cost/1000;
    eos(u).value = value+score_cost;
end