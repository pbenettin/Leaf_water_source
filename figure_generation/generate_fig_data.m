
% make a dual isotope plot to show the data
xinterval=linspace(-15,15,2); %interval of dO18 for the lmwl
lmwl_par=[8.26,11.30]; %slope and intercept of the LMWL
lmwl=lmwl_par(1)*xinterval+lmwl_par(2);  % prepare the lmwl
mks=3; %default marker size
style{1}={'<',':',mks,'k','none',[1 .3 0],'Xylem'}; %xylem
style{2}={'<',':',mks,'k','none',[1 .8 0],'Phloem'}; %phloem
style{3}={'d',':',mks,'k','none',[.2 .3 .2],'Leaves'}; %leaves

figure
hold all
plot([min(xinterval),max(xinterval)],[lmwl(1),lmwl(end)],'--','LineWidth',1,'Color',[0 0 0],...
    'DisplayName','LMWL');
for i=[1,3]
    q = strcmp(T.Type,style{i}{7});
    plot(T.d18O(q),T.d2H(q),...
        style{i}{1},'MarkerSize',style{i}{3},'Color',style{i}{6},...
        'DisplayName',style{i}{7})
end
axis([-14 16 -100 0])
title('\bf collected data','FontSize',12)
xlabel(['\delta^{18}O [',char(8240),']'])
ylabel(['\delta^{2}H [',char(8240),']'])
legend(gca,'Location','NW')
box on
axis square
set(gca,'TickDir','out')