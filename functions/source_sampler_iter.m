function A = source_sampler_iter(d_o,d_o_par,lmwl_par,sigma_H_lmwl,el_distr,ngens)
% function to determine the probable sources of a sample according to
% probable evaporation lines. Adapted from the 'mwlsource' function incuded 
% in the R script watercomp.r by the SPATIAL-Lab:
% https://github.com/SPATIAL-Lab/watercompare 

% highlights: 
% -this source sampler iterates until exactly ngens samples are generated
% -one can input any slope distribution object for the evaporation line
% slope (i.e. can be non Normal)

% Syntax
% A = slope_sampler_iter(d_o,d_o_par,lmwl_par,sigma_H_lmwl,el_distr_name,el_par,ngens);
% A: matrix with d18O and d2H of: sources, observations, the slopes and their probability
% d_o: d18O and d2H of the measured sample
% d_o_par: std of d18O, std of d2H, and their correlation
% lmwl_par: slope and intercept of the LMWL
% sigma_H_lmwl: std of d2H in the LMWL
% el_distr: a probability density function object that defines the pdf of the slopes
% ngens: number of points that will be generated


% few settings
plot_projection=0; % display the result at the end?
sigma_H_h=sigma_H_lmwl; %expected variability (std) in the d2H samples is the same as the variability around the lmwl

% prepare the loop
A=NaN(ngens,6);
maxiter=100000; %max number of iterations allowed
iter=1;
n=1;

%make sure the sample is not a NaN
if any(isnan(d_o)) 
    return 
end 

% find reasonable range for O source by intersecting the mean sample composition 
% with a very flat and steep evaporation lines (e.g. a factor of +-5std)
stdfactor=4;
[pmhigh,~]=project_dualisotope(d_o,[lmwl_par(1),lmwl_par(2)],[el_distr.mean-stdfactor*el_distr.std,1000]);
[pmlow,~]=project_dualisotope(d_o,[lmwl_par(1),lmwl_par(2)],[min(el_distr.mean+stdfactor*el_distr.std,lmwl_par(1)-0.01),1000]);

% make sure the sample does not lie left of the lmwl
if pmhigh(1)<pmlow(1) 
    fprintf('sample lies left of mixing line...\n')
    return
end

% quickly estimate the maximum of the slope distribution (needed for the
% Metropolis test)
N=1000; %number of points for the evaluation of the pdf maximum
x=linspace(el_distr.mean-el_distr.std,el_distr.mean+el_distr.std,N);
max_Sprob=max( pdf(el_distr,x) ); %max slope probability density

% go for the iterations
while n<=ngens
    
    % 1 - OBSERVATION: generate uncertainty around the sample measurement
    mu=[d_o(1),d_o(2)]; %mean d18O and mean d2H of the measured sample
    SIGMA = [d_o_par(1)^2   d_o_par(1)*d_o_par(2)*d_o_par(3);...
        d_o_par(1)*d_o_par(2)*d_o_par(3)    d_o_par(2)^2]; %covariance matrix
    X_o = mvnrnd(mu,SIGMA,1); %X_o: observations. Column 1 is 18O, column 2 is 2H
    
    % 2 - CANDIDATE SOURCE: draw the hypothetical sources from the credible range determined above
    O_h=pmlow(1)+rand*(pmhigh(1)-pmlow(1)); %random number within the range 
    H_h=normrnd(lmwl_par(1)*O_h+lmwl_par(2),sigma_H_h); %normal distribution of draws around the lmwl
    X_h=[O_h,H_h];% X_h: hypothetical sources. Column 1 is 18O, column 2 is 2H
       
    % 3 - ACCEPT/REJECT THE SOURCES: retain the hypothetical sources according to the slope probability
    % for each pair of values, compute the slope of the line that connects a
    % candidate source to an observation point and evaluate its probability
    % according to our imposed evaporation line distribution
    
    % compute the slope and evaluate its probability density
    S=(X_o(1,2)-X_h(1,2))/(X_o(1,1)-X_h(1,1)); %computed slope
    Sprob=pdf(el_distr,S(1)); %slope probability density
    
    % check that you do not exceed the maximum (means the maximum was not
    % accurate)
    if Sprob>max_Sprob*1.01
        error('The maximum slope probability was not accurate enough. Increase the accuracy by increasing the variable N around line 50')
    end
       
    % selection test
    if Sprob>max_Sprob*rand
        A(n,:)=[X_h,X_o,S,Sprob]; %d18O and d2H source, d18O and d2H sample, slope, slope probability
        n=n+1;
    end
    
    % add a check on the iterations to avoid overflows
    iter=iter+1;
    if iter>maxiter
        fprintf('Attention: only %d/%d samples extracted in %d iterations\n',[n-1,ngens,maxiter])
        A(n:end,:)=[];
        break
    end
end


% END - just add a plot if needed
if plot_projection==1
    
    % a few settings
    mksz=5; %marker size for the plot
    show_evaplines=1;
    show_points=1;
    
    % compute the global meteoric water line (it will be used as LMWL)
    xinterval=linspace(min(A(:,1))-1,max(A(:,3)+1)); %interval of dO18 for linear interpolation and plot)
    lmwl=lmwl_par(1)*xinterval+lmwl_par(2);
    
    % get the mean true evaporation line that passes through the observation
    x_meanevap=[xinterval(1),xinterval(end)];
    y_meanevap=el_par(1).*x_meanevap+d_o(2)-el_par(1)*d_o(1);
    
    % build the figure
    figure(33)
    hold all
    
    % lmwl
    gm=plot([min(xinterval),max(xinterval)],[lmwl(1),lmwl(end)],'--','LineWidth',1,'Color',[0 0 0],'DisplayName','LMWL');
    
    % plot all the evaporation lines
    if show_evaplines==1
        for j=1:size(A,1)
            if j==1
                el=plot([A(j,1),A(j,3)],[A(j,2),A(j,4)],'Color',[.8 .8 .8],'LineWidth',.5,...
                    'DisplayName','evaporation lines');
            else
                plot([A(j,1),A(j,3)],[A(j,2),A(j,4)],'Color',[.8 .8 .8],'LineWidth',.5,...
                    'HandleVisibility','off');
            end
        end
    end
    
    if show_points==1
        
        p2=plot(A(:,3),A(:,4),'x','LineWidth',0.5,'DisplayName','sample',...
            'MarkerEdgeColor',[.2 .8 .3],'MarkerFaceColor','y','MarkerSize',mksz);
        
        %         mel=plot(x_meanevap,y_meanevap,'--','LineWidth',1,...
        %             'Color','b','DisplayName','mean evaporation line');
        
        p3=plot(A(:,1),A(:,2),'^','LineWidth',0.5,'DisplayName','sample source',...
            'MarkerEdgeColor',[1 0 0],'MarkerFaceColor','none','MarkerSize',mksz-1);
        
        p4=plot(mean(A(:,1)),mean(A(:,2)),'^','LineWidth',0.5,'DisplayName','mean source',...
            'MarkerEdgeColor',[1 0 0],'MarkerFaceColor','k','MarkerSize',mksz+1);
        
        s=plot(d_o(1),d_o(2),'o','LineWidth',0.5,'DisplayName','mean obs',...
            'MarkerEdgeColor',[.2 .8 .5],'MarkerFaceColor',[.1 .1 .1],'MarkerSize',mksz-1);
    end
    %axis([-13 -4 -100 -10])
    axis([min(A(:,1))-1,max(A(:,3))+1,min(A(:,2))-5,max(A(:,4))+5])
    axis tight
    title('\bf dual-isotope plot','FontSize',12)
    xlabel(['\delta^{18}O [',char(8240),']'])
    ylabel(['\delta^{2}H [',char(8240),']'])
    %legend(gca,'Location','NW')
    box on
    axis square
    set(gca,'TickDir','out')
    
end

end


% function to project a point in a dual isotope space to two lines
% datain: nx2 matrix with d18O and d2H for each datapoint
% coef_mixwl: slope and intercept of the mixing line for the projection
% coef_evapl: slope and intercept of the evaporation line for the projection
function[pm,pe]=project_dualisotope(datain,coef_mixwl,coef_evapl)

% get slope and intercept
sl_m=coef_mixwl(1); y0_m=coef_mixwl(2); %pure mixing line
sl_e=coef_evapl(1); y0_e=coef_evapl(2); %evap line parameters

% transformation matrices 
Am1=1/(sl_m-sl_e)*[-1 1; -sl_m sl_e]; %for projection onto the mixing line
Bm1=1/(sl_e-sl_m)*[-1 1; -sl_e sl_m]; %for projection onto the evap line

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


