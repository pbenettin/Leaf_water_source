% Projecting leaf isotope composition onto its rainfall source on the LMWL
% Paolo Benettin, EPFL, October 2020
%
% Can we use the isotopic composition of leaf water to help infer plant
% water origin? This question is investigated using samples from xylem and
% leaves from a willow tree, collected during the SPIKE II experiment in
% May-June 2018 at EPFL (Switzerland).
% 
% The code is organized as follows:
% - load, and pre-process the data
% - (optional) theory
% - run the sample projection on all samples
% - analyze the results through plots
%--------------------------------------------------------------------------

% prepare the workspace
clear variables
close all
clc
addpath('data')
addpath('functions')
addpath('figure_generation')

% some general settings
flag_theory = 1; %show theory or not

% -------------------------------------------------------------------------
% - LOAD AND PRE-PROCESS THE DATA
% -------------------------------------------------------------------------
% load and process the data 
T = data_load_and_process; %using an external function

% show the isotope data collected during the 43-days experiment
run('generate_fig_data')

% -------------------------------------------------------------------------
% - THEORY: show how we can remove the effect of evaporative fractionation
% -------------------------------------------------------------------------
% If we can characterize the evaporative fractionation trajectory of leaf
% waters, then we can remove the effect of fractionation and trace a sample
% back to its source water on the LMWL. If this trajectory is fairly
% linear, then tracing back the origin is very simple and it works
% regardless of how much fractionation occurs (no need for isotopic
% steady-state).
% A simple linear evaporation trajectory (evaporation line) is assumed in
% the following. To trace samples back to their origin on the LMWL and
% estimate the related uncertainty, I use a methodology very similar to the
% one by Bowen et al., 2018, Oecologia, whose code and documentation can be
% found at https://github.com/SPATIAL-Lab/watercompare.
% A distribution of evaporation lines can be obtained by applying a basic
% application of the Craig-Gordon model (see next section). For our
% experiment evaporation lines are mostly in the range 3.1-3.5.
% -------------------------------------------------------------------------

if flag_theory == 1

% Illustrate the methodology

% select samples of xylem and leaf water on the same day
q = T.time == datetime('04-June-2018 13:35'); %just the selction of one day
leaf_sample = [T.d18O(q & strcmp(T.Type,'Leaves')),...
    T.d2H(q & strcmp(T.Type,'Leaves'))]; %d18O, d2H
xylem_sample = [T.d18O(q & strcmp(T.Type,'Xylem')),...
    T.d2H(q & strcmp(T.Type,'Xylem'))]; %d18O, d2H

% some example settings for the fractionation removal 
ngens=200; %number of generated samples
slope_pdf=makedist('Normal','mu',3.3,'sigma',0.3); %distribution object
lmwl_par=[8.26,11.30]; %slope and intercept of the "source line" for this experiment
sigma_H_lmwl=1; %expected variability (std) in the d2H of the LMWL
d_o_par=[0.05,0.25,.8]; %assumed sample std dO18, std d2H and correlation

% generate the distribution of possible water sources for both samples
A_L = source_sampler_iter(leaf_sample,...
    d_o_par,lmwl_par,sigma_H_lmwl,slope_pdf,ngens);
A_X = source_sampler_iter(xylem_sample,...
    d_o_par,lmwl_par,sigma_H_lmwl,slope_pdf,ngens);

% make a dual isotope plot with the projection
run('generate_fig_theory')

% Comments: The plot above shows that the potential sources of leaf water
% are more uncertain, but they point to the same potential sources as xylem
% water. Indeed, the most probable (mean) sources are rater close in this
% case.

end

% -------------------------------------------------------------------------
% - RUN THE SAMPLE PROJECTION ON ALL THE SAMPLES
% -------------------------------------------------------------------------
% Use the same approach for all the available samples and extract the mean
% and standard deviation of the projected sources.
% 
% The procedure for each sample is:
% 1 - get a distribution of possible evaporation slopes. To do so, use an
% implementation of the Craig-Gordon model with a large number (e.g.
% 10'000) of possible input parameters: aerodynamic parameter (n), humidity
% (hm), temperature (T) and degree of isotopic equilibrium with the
% atmosphere (k). For xylem water, evaporation has occurred in the soil
% roughly in the previous weeks-months and thus the relevant humidity and
% temperatures are computed as averages over the previous 30 days. For leaf
% water, evaporation is mostly within the leaf in hours to days and the
% relevant humity and temperature is considered to be the average in the 24
% hours before sample collection.
% 2 - fit a probability distribution to the empirical slopes (use a
% lognormal rather than normal because the empirical distribution is not
% always simmetric)
% 3 - run the sample projection using the fitted slope distribution
% -------------------------------------------------------------------------

% Settings for the fractionation removal
% general common settings
ngens=100; %number of generated samples
lmwl_par=[8.27,11.41]; %slope and intercept of the LMWL
sigma_H_lmwl=1; %expected variability (std) in the d2H of the mixed sources
d_o_par=[0.12,0.81,.5]; %sample std dO18, std d2H and correlation
iso_source=[-11,-79.6]; %a reference starting point that belongs to the LMWL
flag_method=2; %lake reaching steady-state
nval=10; %number of tested values for each parameter
N=nval^4; %total parameter combinations

% Input parameter ranges (here the ones shared by soil and leaf samples):
dhr_list=linspace(-0.1,+0.1,nval); %spans a +- deviation from the measurement
dT_list=linspace(-3,+3,nval); %spans a +- deviation from the measurement
k_list=linspace(0.75,1,nval);

% Soil-specific settings
n_list_s=linspace(0.75,1,nval); %this is specific to soil
x_s=[0,0.3]; %ratio evaporation to other outfluxes (does not really affect the results)

% Leaf-specific settings
n_list_l=linspace(0.85,1,nval); %this is specific to leaves
x_l=[0,1]; %ratio evaporation to other outfluxes (does not really affect the results)

% build 2 new data tables and update T:
% - a datatable with the distribution of slopes for each sample
% - a datatable with all possible sources for each sample
% - update the original datatable T with the mean slope and mean and std of the projection
tbl_slope = cell2table(cell(0,3),'VariableNames',{'time','type','slope'});
tbl_source = cell2table(cell(0,4),'VariableNames',{'time','type','d18O','d2H'});
T.sl = zeros(size(T,1),1); %preallocate a column for the mean slope
T.mpO = zeros(size(T,1),1); %preallocate a column for the mean oxygen source
T.stdpO = zeros(size(T,1),1); %preallocate a column for the std oxygen source
T.mpH = zeros(size(T,1),1); %preallocate a column for the mean hydrogen source
T.stdpH = zeros(size(T,1),1); %preallocate a column for the std hydrogen source

% loop on each sample
for i=1:size(T,1)
    
    % generate a slope distribution by running the CG model for multiple input parameter combinations
    switch T.Type{i}
        case {'Xylem','Phloem'}
            sl = montecarloCG(n_list_s,T.rhmonth(i)+dhr_list,T.Tmonth(i)+dT_list,k_list,iso_source,flag_method,x_s);
        case 'Leaves'            
            sl = montecarloCG(n_list_l,T.rhday(i) + dhr_list,T.Tday(i) + dT_list,k_list,iso_source,flag_method,x_l);
    end
    
    % fit a distribution to the empirical slope distribution
    %pd = fitdist(sl,'Normal');
    %pd = fitdist(sl,'Gamma');
    pd = fitdist(sl,'LogNormal');
    
    % store slope distribution in a table and append to main table
    tmp=table;
    tmp.time = repmat(T.time(i),length(sl),1);
    tmp.type = repmat(T.Type(i),length(sl),1);
    tmp.slope = sl;    
    tbl_slope = vertcat(tbl_slope,tmp);
    
    % now run the projection for the sample
    src = source_sampler_iter([T.d18O(i),T.d2H(i)],d_o_par,lmwl_par,sigma_H_lmwl,pd,ngens);
    
    % store sources in a table and append to main table
    tmp=table;
    tmp.time = repmat(T.time(i),length(src),1);
    tmp.type = repmat(T.Type(i),length(src),1);
    tmp.d18O = src(:,1);    
    tmp.d2H = src(:,2);    
    tbl_source = vertcat(tbl_source,tmp);
    
    % add summary statistics of the projection to our original T table
    T.sl(i) = mean(sl); %mean slope
    T.mpO(i) = mean(src(:,1)); %mean of the projection for d18O    
    T.stdpO(i) = std(src(:,1)); %std of the projection for d18O
    T.uncpO(i) = quantile(src(:,1), 0.975) - quantile(src(:,1), 0.025); %uncertainty of the projection, computed as the 95% confidence interval
    T.mpH(i) = mean(src(:,2)); %mean of the projection for d18O
    T.stdpH(i) = std(src(:,2)); %std of the projection for d18O
    T.uncpH(i) = quantile(src(:,2), 0.975) - quantile(src(:,2), 0.025); %uncertainty of the projection, computed as the 95% confidence interval
end

% -------------------------------------------------------------------------
% - ANALYZE THE RESULTS THROUGH PLOTS
% -------------------------------------------------------------------------

% First show an example of evaporation line slopes
run('generate_fig_el_slopes')

% Then show results for all samples 
run('generate_fig_projection')
% Comment: despite the uncertainty, the trend in the probable xylem source
% is quite well mimicked by the probable leaf sources. However, there are
% patterns in mid-June that we cannot explain so far. Note this is a period
% when the plant was found to be under water stress.
% The uncertainty in leaf projected source is (much) higher because the
% sample lies (much) further away from the LMWL.

% From now on, compare sources for samples collected on the same day

% Select the sampling days for which all samples are available. Then,
% compute the difference between the mean estimated sources
q = T.time >= '30-may-2018'; %before this date only xylem was collected
Nres = length(unique(T.datecount(q)));
resdates = unique(T.time(q));
res=NaN(Nres,2); %matrix to store the residuals (% [d18O and d2H] of Leaves-Xylem
nn=0;
for i = unique(T.datecount(q))'
    nn=nn+1;
    % check which samples are available
    tmp1 = T.datecount == i & strcmp(T.Type,'Xylem');
    tmp3 = T.datecount == i & strcmp(T.Type,'Leaves');
    
    % compute the difference among the mean sources  
    if sum(tmp1) ~= 0 && sum(tmp3) ~= 0
        res(nn,1) = mean(T.mpO(tmp3))-mean(T.mpO(tmp1));
        res(nn,2) = mean(T.mpH(tmp3))-mean(T.mpH(tmp1));
    end
end

% compute the mean and std of the residuals
mres = nanmean(res);
stdres = nanstd(res);

% display something
fprintf('mean res (d18O,d2H) L-X: %.2f, %.2f\n',mres([1,2]))
fprintf('std res (d18O,d2H) L-X: %.2f, %.2f\n',stdres([1,2]))

% pass unique sampling days to the source table
tbl_source = join(tbl_source, unique(T(:,{'time','datecount'})));

% generate a figure with the residuals
run('generate_fig_residuals')
% comments: the residuals' timeseries (above) shows that the residuals of the
% projected leaf-xylem values have: Average: 2.3permil $\delta^{2}H$,
% standar deviations: 0.8permil $\delta^{18}O$, 6.9permil in $\delta^{2}H$.
% There is a sistematic error around June 20th, possibly related to the
% very dry conditions around those days.

% The uncertainty on the mean origin is further explored using boxplot (on
% $\delta^{18}O$ only, for simplicity) and it is compared with typical
% monthly rainfall variability
run('generate_fig_boxplot')



% eof