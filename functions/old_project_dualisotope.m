% function to project a point in a dual isotope space to two lines

% datain: nx2 matrix with d18O and d2H for each datapoint
% coef_mixwl: slope and intercept of the mixing line for the projection
% coef_evapl: slope and intercept of the evaporation line for the projection


function[pm,pe]=project_dualisotope(datain,coef_mixwl,coef_evapl)

% get slope and intercept
sl_m=coef_mixwl(1); y0_m=coef_mixwl(2); %pure mixing line
sl_e=coef_evapl(1); y0_e=coef_evapl(2); %evap line parameters

% transformation matrices 
Am1=1/(coef_mixwl(1)-coef_evapl(1))*[-1 1; -coef_mixwl(1) coef_evapl(1)]; %for projection onto the mixing line
Bm1=1/(coef_evapl(1)-coef_mixwl(1))*[-1 1; -coef_evapl(1) coef_mixwl(1)]; %for projection onto the evap line

% preallocate projection points (pm=projection over mixing line, pe=proj. over evap. line)
pm=zeros(size(datain));
pe=zeros(size(datain));

% project points
for i=1:size(datain,1)    
    xA=datain(i,1); yA=datain(i,2); %coordinates of the point to be projected
    b=[sl_e*xA-yA; -y0_m];   
    d=[sl_m*xA-yA; -y0_e];
    pm(i,:)=Am1*b; %projection on the mixing line
    pe(i,:)=Bm1*d; %projection on the evaporation line
end



end
