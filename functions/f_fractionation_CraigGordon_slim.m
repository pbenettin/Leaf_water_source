function Slel = f_fractionation_CraigGordon_slim(inputpar,iso_source,flag_method,x)
% code to compute isotope evaporative fractionation according to the theory
% of Craig-Gordon 1965

% in particular, this function returns the slope(s) of the evaporation
% line(s) as the slope of the line that connects the origin with the
% asymptotic or steady-state value. As nonlinearities are mild, it is easy
% to verify that the same slope holds even if asympotic value or
% steady-state has not been reached in reality.

% inputs:
% inputspar: [n, hm, Tc, k] input parameters
% iso_source: [d18O and d2H] of the source water
% flag_method: 1 = desiccating water body, 2 = lake at steady state
% x: depending on flag method, it is either the ratio
    % (evaporated water) / (initial water) or the ratio evaporation / input

%--------------------------------------------------------------------------
% notation
%--------------------------------------------------------------------------

% NOTE: PERMIL NOTATION (--> epse and epsk are expressed in permil)
% dv: isotopic content of the residual liquid (sometimes referred to as dS)
% ds: isotopic content of the residual liquid (sometimes referred to as dV)
% di: isotopic composition of incoming precipitation
% de: isotopic content of the evaporating flux
% da: isotopic content of the ambient athmospheric vapor (atmospheric moisture)
% dp: isotopic content of precipitation, for computation of equilibrium da
% alphae: fractionation factor at equilibrium (Rliq/Rvap)
% epse=alphae-1: equilibrium fractionation factor (expressed in permil) 
% Tc: Temperature [degree Celsius]
% Tk: Temperature [Kelvin]
% hm: relative humidity in [0,1]
% n: aerodinamic regime parameter [-]
% theta: [-] term to account for feedbacks between the water body and the atmosphere
% Dr: ratio between the diffusivities of the heavy and light isotopes [-]
% k: factor to simulate non-equilibrium with the atmosphere
% epsk: kinetic fractionation factor (expressed in permil) 
% x: ratio (evaporated water)/(initial water) or ratio evaporation/input [-]

%--------------------------------------------------------------------------
% parameters and settings
%--------------------------------------------------------------------------

% input parameters
n=inputpar(1);
hm=inputpar(2);
Tc=inputpar(3);
k=inputpar(4);

% constants for kinetic fractionation
theta=1; %atmospheric feedback factor (theta=1 for no feedback)
Dr_H=0.9755; %from Merlivat 1978
Dr_O=0.9723; %from Merlivat 1978

% isotopic composition of rainfall (for computation of atmospheric vapor composition)
dp_O=iso_source(1); %equal to the source (different da values are then obtained by changing k)
dp_H=iso_source(2); %equal to the source (different da values are then obtained by changing k)

%--------------------------------------------------------------------------
% computations (all in permil notation)
%--------------------------------------------------------------------------
% get equilibrium fractionation factors from Horita and Wesolowski (1994)
Tk=Tc+273.15;
alphae_H=exp(1/1000.*(1158.8*Tk.^3/10^9-1620.1*Tk.^2/10^6+...
    794.84*Tk./10^3-161.04+2.9992*10^9./Tk.^3));
alphae_O=exp(1/1000.*(-7.685+6.7123*10^3./Tk-1.6664*10^6./Tk.^2+...
    0.3504*10^9./Tk.^3));
epse_H=(alphae_H-1)*1000; %permil notation
epse_O=(alphae_O-1)*1000; %permil notation

% get kinetic fractionation factors (approach by Horita et al. 2008)
epsk_H=n*theta*(1-Dr_H)*1000*(1-hm); %permil notation
epsk_O=n*theta*(1-Dr_O)*1000*(1-hm); %permil notation

% get atmospheric composition from precipitation-equilibrium assumption (Gibson et al., 2008)
% note I assume monthly precipitation of the Leman area
da_H=(dp_H-k*epse_H)./(1+k*epse_H*10^-3);
da_O=(dp_O-k*epse_O)./(1+k*epse_O*10^-3);

% compute useful variables m and dstar ('enrichment slope' and limiting isotopic composition)
m_H=(hm-10^-3*(epsk_H+epse_H./alphae_H))./(1-hm+10^-3*epsk_H); %'enrichment slope' (Gibson et al.(2016))
m_O=(hm-10^-3*(epsk_O+epse_O./alphae_O))./(1-hm+10^-3*epsk_O); %'enrichment slope' (Gibson et al.(2016))
dstar_H=(hm.*da_H+epsk_H+epse_H./alphae_H)/(hm-10^-3*(epsk_H+epse_H./alphae_H)); %this is A/B in Gonfiantini 1986
dstar_O=(hm.*da_O+epsk_O+epse_O./alphae_O)/(hm-10^-3*(epsk_O+epse_O./alphae_O)); %this is A/B in Gonfiantini 1986

% compute asymptotic value of residual water
if flag_method==1
    ds_H=(dp_H-dstar_H).*(1-x).^m_H+dstar_H; %desiccating water body
    ds_O=(dp_O-dstar_O).*(1-x).^m_O+dstar_O; %desiccating water body
end
if flag_method==2
    ds_H=(x.*m_H.*dstar_H+dp_H)./(1+m_H.*x); %this is the asymptotic value for a lake/soil that reaches steady state
    ds_O=(x.*m_O.*dstar_O+dp_O)./(1+m_O.*x); %this is the asymptotic value for a lake/soil that reaches steady state
end

% get the slope of the evaporation line as the line connecting start and end points
Slel=(ds_H(end)-dp_H)./(ds_O(end)-dp_O); %approximation of the evaporation line

% alternative: compute the slope by interpolation over multiple points
% [lint,~]=polyfit(ds_O(:,i),ds_H(:,i),1);
% Slel=lint(1);
% fprintf('empiric slope = %.2f\n',lint(1))

% compute vapor isotopic composition (Craig and Gordon 1965, formula with notation by Gibson 2016)
% dE_H=((ds_H-epse_H)/alphae_H-hm.*da_H-epsk_H)./(1-hm+10^-3*epsk_H); %permil notation
% dE_O=((ds_O-epse_O)/alphae_O-hm.*da_O-epsk_O)./(1-hm+10^-3*epsk_O); %permil notation
   

end
