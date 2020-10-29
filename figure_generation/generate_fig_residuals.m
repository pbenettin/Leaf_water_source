% show the residuals in a timeseries
xd=datetime([{'28-May-2018'},{'01-Jul-2018'}])';
mks=3;

figure
set(gcf,'Units','centimeters','Position',[5 5 25 7])

subplot(1,2,1); set(gca,'Nextplot','add','box','on','TickDir','out')
title('\delta^{18}O residuals')
plot(resdates,res(:,1),'o-','MarkerSize',mks,'DisplayName','L-X','DisplayName','Leaf-Xylem')
plot([T.time(1),T.time(end)],[0,0],'k','HandleVisibility','off')
%grid on
%ylim([-3,1])
ylim([-2,2])
xlim(xd)
%datetick('x','keeplimits')
legend(gca,'Location','SouthWest')
ylabel(['\delta^{18}O [',char(8240),']'])

subplot(1,2,2); set(gca,'Nextplot','add','box','on','TickDir','out')
title('\delta^{2}H residuals')
plot(resdates,res(:,2),'o-','MarkerSize',mks,'DisplayName','L-X','DisplayName','Leaf-Xylem')
plot([T.time(1),T.time(end)],[0,0],'k','HandleVisibility','off')
%grid on
%ylim([-25,10])
ylim([-16,16])
xlim(xd)
%datetick('x','keeplimits')
ylabel(['\delta^{2}H [',char(8240),']'])