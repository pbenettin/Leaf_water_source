% make a dual-isotope plot
xinterval=linspace(-15,15,2); %interval of dO18 for the lmwl
%xinterval=linspace(-15,-6,2); %interval of dO18 for the lmwl
lmwl=lmwl_par(1)*xinterval+lmwl_par(2);  % prepare the lmwl
mksz=6; %default markersize
col_L=[[.1 .9 .1];[.9 1 .9];[.2 .8 .2]]; %colors for leave samples
col_X=[[.9 .1 .1];[1 .9 .9];[.8 .2 .2]]; %colors for xylem samples

figure
hold all
gm=plot([min(xinterval),max(xinterval)],[lmwl(1),lmwl(end)],'--','LineWidth',1,'Color',[0 0 0],'DisplayName','LMWL');

% leaves
A=A_L; col=col_L;
for j=1:size(A,1)
    plot([A(j,1),A(j,3)],[A(j,2),A(j,4)],'Color',col(2,:),'LineWidth',.5,...
        'DisplayName','evaporation lines','HandleVisibility','off');
end
plot(A(:,3),A(:,4),'x','LineWidth',0.5,'DisplayName','Leaf sample',...
 'MarkerEdgeColor',col(1,:),'MarkerFaceColor','y','MarkerSize',mksz,'HandleVisibility','off');
pLs=plot(A(:,1),A(:,2),'^','LineWidth',0.5,'DisplayName','Leaf compatible sources',...
 'MarkerEdgeColor',col(1,:),'MarkerFaceColor','none','MarkerSize',mksz-1);

% Xylem
A=A_X; col=col_X;
for j=1:size(A,1)
    plot([A(j,1),A(j,3)],[A(j,2),A(j,4)],'Color',col(2,:),'LineWidth',.5,...
        'DisplayName','evaporation lines','HandleVisibility','off');
end
plot(A(:,3),A(:,4),'x','LineWidth',0.5,'DisplayName','Xylem sample',...
 'MarkerEdgeColor',col(1,:),'MarkerFaceColor','y','MarkerSize',mksz,'HandleVisibility','off');
pXs=plot(A(:,1),A(:,2),'^','LineWidth',0.5,'DisplayName','Xylem compatible sources',...
 'MarkerEdgeColor',col(1,:),'MarkerFaceColor','none','MarkerSize',mksz-1);

% plot mean sample and mean source for both xylem and phloem
A=A_L; col=col_L;
pmLs=plot(mean(A(:,1)),mean(A(:,2)),'p','LineWidth',0.5,'DisplayName','estimated mean Leaf source',...
 'MarkerEdgeColor','k','MarkerFaceColor',col(1,:),'MarkerSize',mksz+1);
pL=plot(mean(A(:,3)),mean(A(:,4)),'o','LineWidth',0.5,'DisplayName','Leaf sample',...
 'MarkerEdgeColor','k','MarkerFaceColor',col(1,:),'MarkerSize',mksz-1);
A=A_X; col=col_X;
pmXs=plot(mean(A(:,1)),mean(A(:,2)),'p','LineWidth',0.5,'DisplayName','estimated mean Xylem source',...
 'MarkerEdgeColor','k','MarkerFaceColor',col(1,:),'MarkerSize',mksz+1);
pX=plot(mean(A(:,3)),mean(A(:,4)),'o','LineWidth',0.5,'DisplayName','Xylem sample',...
 'MarkerEdgeColor','k','MarkerFaceColor',col(1,:),'MarkerSize',mksz-1);

% finish the plot
axis([-14 3 -100 -10])
%title('\bf source tracing example','FontSize',12)
xlabel(['\delta^{18}O [',char(8240),']'])
ylabel(['\delta^{2}H [',char(8240),']'])
legend([pL,pX,pLs,pXs,pmLs,pmXs])
legend(gca,'Location','NW')
box on
axis square
set(gca,'TickDir','out'); %legend boxoff

% ADD graphically error bars with MEAN AND STD SOMEWHERE in the plot
%{
y_ox = -12;
x_hy = 2;

% plot mean sample and mean source for both xylem and phloem
A=A_L; col=col_L;
% Leaf oxygen
pmLs=errorbar(mean(A(:,1)),y_ox,std(A(:,1)),'horizontal',...
    'p','LineWidth',0.5,'DisplayName','estimated mean Leaf source',...
    'Color',col(1,:),'MarkerEdgeColor','k','MarkerFaceColor',col(1,:),'MarkerSize',mksz+1,...
    'HandleVisibility','off');
pL=plot(mean(A(:,3)),y_ox,'o','LineWidth',0.5,'DisplayName','Leaf sample',...
 'MarkerEdgeColor','k','MarkerFaceColor',col(1,:),'MarkerSize',mksz-1,'HandleVisibility','off');
% Leaf hydrogen
pmLs=errorbar(x_hy,mean(A(:,2)),std(A(:,2)),'vertical',...
    'p','LineWidth',0.5,'DisplayName','estimated mean Leaf source',...
    'Color',col(1,:),'MarkerEdgeColor','k','MarkerFaceColor',col(1,:),'MarkerSize',mksz+1,...
    'HandleVisibility','off');
pL=plot(x_hy,mean(A(:,4)),'o','LineWidth',0.5,'DisplayName','Leaf sample',...
 'MarkerEdgeColor','k','MarkerFaceColor',col(1,:),'MarkerSize',mksz-1,'HandleVisibility','off');

A=A_X; col=col_X;
% Xylem oxygen
pmXs=errorbar(mean(A(:,1)),y_ox,std(A(:,1)),'horizontal',...
    'p','LineWidth',0.5,'DisplayName','estimated mean Xylem source',...
    'COlor',col(1,:),'MarkerEdgeColor','k','MarkerFaceColor',col(1,:),'MarkerSize',mksz+1,...
    'HandleVisibility','off');
pX=plot(mean(A(:,3)),y_ox,'o','LineWidth',0.5,'DisplayName','Xylem sample',...
 'MarkerEdgeColor','k','MarkerFaceColor',col(1,:),'MarkerSize',mksz-1,'HandleVisibility','off');
% Xylem hydrogen
pmXs=errorbar(x_hy,mean(A(:,2)),std(A(:,2)),'vertical',...
    'p','LineWidth',0.5,'DisplayName','estimated mean Xylem source',...
    'Color',col(1,:),'MarkerEdgeColor','k','MarkerFaceColor',col(1,:),'MarkerSize',mksz+1,...
    'HandleVisibility','off');
pX=plot(x_hy,mean(A(:,4)),'o','LineWidth',0.5,'DisplayName','Xylem sample',...
 'MarkerEdgeColor','k','MarkerFaceColor',col(1,:),'MarkerSize',mksz-1,'HandleVisibility','off');

%}

% also show results separately for d18O and d2H
%{
figure
subplot(1,2,1)
hold all
plot(A_L(:,1),'^','LineWidth',0.5,'DisplayName','Leaf water origin',...
 'MarkerEdgeColor',col_L(1,:),'MarkerFaceColor','none','MarkerSize',mksz-1);
plot([1,length(A_L(:,1))],[mean(A_L(:,1))-std(A_L(:,1)),mean(A_L(:,1))-std(A_L(:,1))],...
    '-','Color',col_L(3,:),'HandleVisibility','off')
plot([1,length(A_L(:,1))],[mean(A_L(:,1))+std(A_L(:,1)),mean(A_L(:,1))+std(A_L(:,1))],...
    '-','Color',col_L(3,:),'HandleVisibility','off')
plot(A_X(:,1),'^','LineWidth',0.5,'DisplayName','Xylem water origin',...
 'MarkerEdgeColor',col_X(1,:),'MarkerFaceColor','none','MarkerSize',mksz-1);
plot([1,length(A_X(:,1))],[mean(A_X(:,1))-std(A_X(:,1)),mean(A_X(:,1))-std(A_X(:,1))],...
    '-','Color',col_X(3,:),'HandleVisibility','off')
plot([1,length(A_X(:,1))],[mean(A_X(:,1))+std(A_X(:,1)),mean(A_X(:,1))+std(A_X(:,1))],...
    '-','Color',col_X(3,:),'HandleVisibility','off')
ylabel(['\delta^{18}O [',char(8240),']'])
xlabel('sample number')
set(gca,'TickDir','out')
title('\delta^{18}O')
box on

subplot(1,2,2)
hold all
plot(A_L(:,2),'^','LineWidth',0.5,'DisplayName','Leaf water origin',...
 'MarkerEdgeColor',col_L(1,:),'MarkerFaceColor','none','MarkerSize',mksz-1);
plot([1,length(A_L(:,2))],[mean(A_L(:,2))-std(A_L(:,2)),mean(A_L(:,2))-std(A_L(:,2))],...
    '-','Color',col_L(3,:),'HandleVisibility','off')
plot([1,length(A_L(:,2))],[mean(A_L(:,2))+std(A_L(:,2)),mean(A_L(:,2))+std(A_L(:,2))],...
    '-','Color',col_L(3,:),'HandleVisibility','off')
plot(A_X(:,2),'^','LineWidth',0.5,'DisplayName','Xylem water origin',...
 'MarkerEdgeColor',col_X(1,:),'MarkerFaceColor','none','MarkerSize',mksz-1);
plot([1,length(A_X(:,2))],[mean(A_X(:,2))-std(A_X(:,2)),mean(A_X(:,2))-std(A_X(:,2))],...
    '-','Color',col_X(3,:),'HandleVisibility','off')
plot([1,length(A_X(:,2))],[mean(A_X(:,2))+std(A_X(:,2)),mean(A_X(:,2))+std(A_X(:,2))],...
    '-','Color',col_X(3,:),'HandleVisibility','off')
ylabel(['\delta^{2}H [',char(8240),']'])
xlabel('sample number')
set(gca,'TickDir','out')
title('\delta^{2}H')
box on
%}


% same things, just with different coloring and symbols (more similar with
% the rest of the plots)
% make a dual-isotope plot
xinterval=linspace(-15,15,2); %interval of dO18 for the lmwl
%xinterval=linspace(-15,-6,2); %interval of dO18 for the lmwl
lmwl=lmwl_par(1)*xinterval+lmwl_par(2);  % prepare the lmwl
mksz=6; %default markersize
col_L=[[.2 .3 .2];[.9 .9 .9]]; %colors for leaf samples
col_X=[[1 .3 0];[.9 .8 .6]]; %colors for xylem samples

figure
hold all
gm=plot([min(xinterval),max(xinterval)],[lmwl(1),lmwl(end)],'--','LineWidth',1,'Color',[0 0 0],'DisplayName','LMWL');

% leaves
A=A_L; col=col_L;
for j=1:size(A,1)
    plot([A(j,1),A(j,3)],[A(j,2),A(j,4)],'Color',col(2,:),'LineWidth',.5,...
        'DisplayName','evaporation lines','HandleVisibility','off');
end
plot(A(:,3),A(:,4),'x','LineWidth',0.5,'DisplayName','Leaf sample',...
 'MarkerEdgeColor',col(1,:),'MarkerSize',mksz,'HandleVisibility','off');
pLs=plot(A(:,1),A(:,2),'o','LineWidth',0.5,'DisplayName','Leaf compatible sources',...
 'MarkerEdgeColor',col(1,:),'MarkerFaceColor','none','MarkerSize',mksz-2);

% Xylem
A=A_X; col=col_X;
for j=1:size(A,1)
    plot([A(j,1),A(j,3)],[A(j,2),A(j,4)],'Color',col(2,:),'LineWidth',.5,...
        'DisplayName','evaporation lines','HandleVisibility','off');
end
plot(A(:,3),A(:,4),'x','LineWidth',0.5,'DisplayName','Xylem sample',...
 'MarkerEdgeColor',col(1,:),'MarkerFaceColor','y','MarkerSize',mksz,'HandleVisibility','off');
pXs=plot(A(:,1),A(:,2),'o','LineWidth',0.5,'DisplayName','Xylem compatible sources',...
 'MarkerEdgeColor',col(1,:),'MarkerFaceColor','none','MarkerSize',mksz-2);

% plot mean sample and mean source for both xylem and phloem
A=A_L; col=col_L;
pmLs=plot(mean(A(:,1)),mean(A(:,2)),'p','LineWidth',0.5,'DisplayName','estimated mean Leaf source',...
 'MarkerEdgeColor','k','MarkerFaceColor',col(1,:),'MarkerSize',mksz+1);
pL=plot(mean(A(:,3)),mean(A(:,4)),'d','LineWidth',0.5,'DisplayName','Leaf sample',...
 'MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',mksz-1);
A=A_X; col=col_X;
pmXs=plot(mean(A(:,1)),mean(A(:,2)),'p','LineWidth',0.5,'DisplayName','estimated mean Xylem source',...
 'MarkerEdgeColor','k','MarkerFaceColor',col(1,:),'MarkerSize',mksz+1);
pX=plot(mean(A(:,3)),mean(A(:,4)),'<','LineWidth',0.5,'DisplayName','Xylem sample',...
 'MarkerEdgeColor','k','MarkerFaceColor',col(1,:),'MarkerSize',mksz-1);

% finish the plot
axis([-14 3 -100 -10])
%title('\bf source tracing example','FontSize',12)
xlabel(['\delta^{18}O [',char(8240),']'])
ylabel(['\delta^{2}H [',char(8240),']'])
legend([pL,pX,pLs,pXs,pmLs,pmXs])
legend(gca,'Location','NW')
box on
axis square
set(gca,'TickDir','out'); %legend boxoff

