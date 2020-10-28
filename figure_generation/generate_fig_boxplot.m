% quick way to display boxplots of the inferred sources

% settings
yl=[-16 -2]; %ylim for all plots
col_X=[1 .3 0];
col_P=[1 .8 0];
col_L=[.2 .3 .2];
col_Rain=[0,0,1];

% need to first run the plant isotope source file

% get to mean leman data
% download data from IAEA/WMO(2020): Global network of isotopes in
% precipitation. The GNIP database. Accessible at:
% https://nucleus.iaea.org/wiser  
filename='tests/wiser_gnip-monthly-ch-gnipmch01.csv'; 
T2=readtable(filename,'ReadVariableNames',false,'HeaderLines',1);
T2.Properties.VariableNames=[{'Group'}    {'Project'}    {'Site'}    {'Country'},...
    {'WMOCode'}    {'Latitude'}    {'Longitude'}    {'Altitude'}    {'TypeOfSite'},...
    {'SourceOfInforma…'}    {'SampleName'}    {'MediaType'}    {'Date'},...
    {'BeginOfPeriod'}    {'EndOfPeriod'}    {'Comment'}    {'O18'}  {'O18Provider'},...
    {'H2'}    {'H2Provider'}    {'H3'}    {'H3Error'}    {'H3Provider'},...
    {'Precipitation'}    {'AirTemperature'}    {'VapourPressure'}]; 
T2.Date=datetime(T2.Date,'InputFormat','yyyy-MM-dd');
month_data_18O=reshape(T2.O18,12,27)';
month_data_2H=reshape(T2.H2,12,27)';

% settings
q = tbl_source.time > datetime('30-May-2018'); 
%q = tbl_source.time > datetime('03-Jun-2018'); % all samples are available
%poss=unique(tbl_source.datecount(q));
pstyle='traditional'; %'traditional' or 'compact'
bstyle='filled'; %'filled' or 'outline'
otsize=2; 

% select seasonal sources to show
sel=[1:7]; %from January to July
Xlab={'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};

% prepare the figure and the subplots
fbox = figure('Units','centimeters','Position',[5 5 25 8]);
posl = [0.11 0.16 0.20 0.73];
posr = [0.41 0.16 0.50 0.73];
axl = axes('Parent',fbox,'Position',posl);
axr = axes('Parent',fbox,'Position',posr,'NextPlot','add');

% left panel
set(fbox, 'currentaxes', axl);
boxplot(month_data_18O(:,sel),'Colors',col_Rain,'Symbol','+','OutlierSize',otsize,'PlotStyle',pstyle,'BoxStyle',bstyle)
title('Rain sources')
set(gca,'TickDir','out','box','on','YLim',yl,'XTickLabel',Xlab(sel))
%grid on
ylabel(['\delta^{18}O [',char(8240),']'])
%xlabel('month')

% right panel: use the table with all sources
set(fbox, 'currentaxes', axr);
qq = q & strcmp(tbl_source.type,'Leaves');
poss=unique(tbl_source.datecount(qq));
boxplot(tbl_source.d18O(qq),tbl_source.datecount(qq),...
    'Positions',poss+0.2,    'Colors',col_L,'Symbol','+','OutlierSize',otsize,'PlotStyle',pstyle,'BoxStyle',bstyle)
% qq = q & strcmp(tbl_source.type,'Phloem');
% poss=unique(tbl_source.datecount(qq));
% boxplot(tbl_source.d18O(qq),tbl_source.datecount(qq),...
%     'Positions',poss+0.2,'Colors',col_P,'Symbol','+','OutlierSize',otsize,'PlotStyle',pstyle,'BoxStyle',bstyle)
qq = q & strcmp(tbl_source.type,'Xylem');
poss=unique(tbl_source.datecount(qq));
boxplot(tbl_source.d18O(qq),tbl_source.datecount(qq),...
    'Positions',poss+0.4,'Colors',col_X,'Symbol','+','OutlierSize',otsize,'PlotStyle',pstyle,'BoxStyle',bstyle)
title('Inferred sources')
set(gca,'TickDir','out','box','on','YLim',yl)
%grid on
ylabel(['\delta^{18}O [',char(8240),']'])
xlabel('sample number')

% workaround to add a legend
tmp = findall(gca,'Tag','Box');
%hLegend = legend([tmp(1),tmp(1+26),tmp(1+26*2)],{'Xylem','Phloem','Leaves'});
hLegend = legend([tmp(1),tmp(1+26)],{'Xylem','Leaves'});

% reset the axes size
set(axl,'Position',posl);
set(axr,'Position',posr);

% save the figure
%printfig('C:\Users\benettin\Dropbox\articoli\Leaf_water\figs\boxplot','png')
