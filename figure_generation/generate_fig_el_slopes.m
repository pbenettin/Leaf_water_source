% figures showing the distribution of evaporation line slopes

% choose a day and show xylem and leaf evaporation slope distributions
sel_list = datetime({'14-Jun-2018 15:15','29-Jun-2018 15:00'});
%sel_list = [T.time(35),T.time(100)];

% show the parameters used to run the Craig-Gordon model for the first
% sample
sel = sel_list(1);
s = find(T.time == sel,1,'first'); %selection of the sample
fprintf('Example of input parameters for sample on %s:\n',T.time(s))
fprintf('{h month} in [%.2f, %.2f]\n',T.rhmonth(s)+min(dhr_list)*100,T.rhmonth(s)+max(dhr_list)*100);
fprintf('{h day} in [%.2f, %.2f]\n',T.rhday(s)+min(dhr_list)*100,T.rhday(s)+max(dhr_list)*100);
fprintf('{T month} in [%.2f, %.2f]\n',T.Tmonth(s)+min(dT_list),T.Tmonth(s)+max(dT_list));
fprintf('{T day} in [%.2f, %.2f]\n',T.Tday(s)+min(dT_list),T.Tday(s)+max(dT_list));
fprintf('{k atmosphere} in [%.2f, %.2f]\n',min(k_list),max(k_list));
fprintf('{n soil} in [%.2f, %.2f]\n',0.75,1);
fprintf('{n leaf} in [%.2f, %.2f]\n',0.85,1);
disp(' ')



% a hystogram + fitting distribution with a distribution of slopes on the
% same day

% some style settings
col_X=[1 .3 0];
col_P=[1 .8 0];
col_L=[.2 .3 .2];

% make the figure
fig_slopes = figure('Units','centimeters','Position',[5 5 25 6]);

%select a sample to show 
sel=sel_list(1); 

% fit a pdf to the empirical distributions
x=linspace(2.5,5,100);
q_s = tbl_slope.time == sel & strcmp(tbl_slope.type,'Xylem'); %query the xylem slopes on that day
q_l = tbl_slope.time == sel & strcmp(tbl_slope.type,'Leaves'); %query the leaf slopes on that day
pd_s = fitdist(tbl_slope.slope(q_s),'LogNormal');
pd_l = fitdist(tbl_slope.slope(q_l),'LogNormal');

% show in a plot
s1=subplot(1,2,1);
set(gca,'NextPlot','add','TickDir','out')
hold all
histogram(tbl_slope.slope(q_l),'Normalization','pdf',...
    'EdgeColor','none','FaceColor',col_L,'FaceAlpha',.4,...
    'DisplayName','Leaf empirical'); 
plot(x,pdf(pd_l,x),'Color',col_L,'LineWidth',2,'DisplayName','Leaf fitted')
histogram(tbl_slope.slope(q_s),'Normalization','pdf',...
    'EdgeColor','none','FaceColor',col_X,'FaceAlpha',.4,...
    'DisplayName','Xylem empirical'); 
plot(x,pdf(pd_s,x),'Color',col_X,'LineWidth',2,'DisplayName','Xylem fitted')
title(sprintf('Distributions of evaporation lines on %s',sel))
legend('show'); legend('boxoff')
xlabel('evaporation line slope [-]')
ylabel('pdf [-]')


%select a sample to show 
sel=sel_list(2); 

% fit a pdf to the empirical distributions
x=linspace(2.5,5,100);
q_s = tbl_slope.time == datetime(sel) & strcmp(tbl_slope.type,'Xylem'); %query the xylem slopes on that day
q_l = tbl_slope.time == datetime(sel) & strcmp(tbl_slope.type,'Leaves'); %query the leaf slopes on that day
pd_s = fitdist(tbl_slope.slope(q_s),'LogNormal');
pd_l = fitdist(tbl_slope.slope(q_l),'LogNormal');

% show in a plot
s2=subplot(1,2,2);
set(gca,'NextPlot','add','TickDir','out')
hold all
histogram(tbl_slope.slope(q_l),'Normalization','pdf',...
    'EdgeColor','none','FaceColor',col_L,'FaceAlpha',.4,...
    'DisplayName','Leaf empirical'); 
plot(x,pdf(pd_l,x),'Color',col_L,'LineWidth',2,'DisplayName','Leaf fitted')
histogram(tbl_slope.slope(q_s),'Normalization','pdf',...
    'EdgeColor','none','FaceColor',col_X,'FaceAlpha',.4,...
    'DisplayName','Xylem empirical'); 
plot(x,pdf(pd_s,x),'Color',col_X,'LineWidth',2,'DisplayName','Xylem fitted')
title(sprintf('Distributions of evaporation lines on %s',sel))
legend('show'); legend('boxoff')
xlabel('evaporation line slope [-]')
ylabel('pdf [-]')

% set a common y axis for both plots
set(s1,'YLim',max([get(s1,'YLim');get(s2,'YLim')]))
set(s2,'YLim',max([get(s1,'YLim');get(s2,'YLim')]))

