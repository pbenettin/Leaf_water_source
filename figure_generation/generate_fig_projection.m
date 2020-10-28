% make here figures with the effects of projection
% select what to plot
flag_plotall = 1; %show projection for all samples
flag_plotdetail = 0; %details of the period where the approach is less accurate 
flag_plotdualisotope = 1; %dual isotope plot with illustrated projection

% some general settings
%col=lines(3);
mks=3; %default marker size
style{1}={'<',':',mks,'k','none',[1 .3 0],'Xylem'}; %xylem
style{2}={'<',':',mks,'k','none',[1 .8 0],'Phloem'}; %phloem
style{3}={'d',':',mks,'k','none',[.2 .3 .2],'Leaves'}; %leaves
ydO1=[-13,12]; %18O limits for pre-projection plots
ydO2=[-13,-8]; %18O limits for post-projection plots
ydH1=lmwl_par(1)*ydO1+lmwl_par(2); %2H limits for pre-projection plots
ydH2=lmwl_par(1)*ydO2+lmwl_par(2); %2H limits for post-projection plots
%q = hour(T.time)>=11 & hour(T.time)<17; %SELECTING DAY SAMPLES ONLY
q = hour(T.time)>=0 & hour(T.time)<=24; %selecting all samples
%q = T.time > '30-May-2018'; %selecting samples when all leave samples are available
xd=datenum([min(T.time(q))-1 max(T.time(q))+2]); %xlimits for the plot


% 1 - FIGURE with all the samples
if flag_plotall == 1

    % timeseries before and after the projection
    figure
    set(gcf,'Units','centimeters','Position',[5 5 25 14])
    sp1=subplot(2,2,1);
    hold all
    for i=[1,3]
        qq = q & strcmp(T.Type,style{i}{7}); %select each sample type
        plot(datenum(T.time(qq)),T.d18O(qq),... 
            style{i}{1},'LineStyle',style{i}{2},'MarkerSize',style{i}{3},'Color',style{i}{6},...
            'DisplayName',style{i}{7})
    end
    xlim(xd)
    ylim(ydO1)
    datetick('x','keeplimits')
    set(gca,'TickDir','out','box','on')
    title('\delta^{18}O (sample, before projection)')
    ylabel(['\delta^{18}O [',char(8240),']'])


    sp2=subplot(2,2,2);
    hold all
    for i=[1,3]
        qq = q & strcmp(T.Type,style{i}{7}); %select each sample type
        plot(datenum(T.time(qq)),T.d2H(qq),... 
            style{i}{1},'LineStyle',style{i}{2},'MarkerSize',style{i}{3},'Color',style{i}{6},...
            'DisplayName',style{i}{7})
    end
    xlim(xd)
    ylim(ydH1)
    datetick('x','keeplimits')
    set(gca,'TickDir','out','box','on')
    title('\delta^{2}H (sample, before projection)')
    ylabel(['\delta^{2}H [',char(8240),']'])

    sp3=subplot(2,2,3);
    hold all
    for i=[1,3]
        qq = q & strcmp(T.Type,style{i}{7}); %select each sample type
        errorbar(datenum(T.time(qq)),T.mpO(qq),T.stdpO(qq),... 
            style{i}{1},'LineStyle',style{i}{2},'MarkerSize',style{i}{3},'Color',style{i}{6},...
            'DisplayName',style{i}{7})
    end
    xlim(xd)
    ylim(ydO2)
    datetick('x','keeplimits')
    legend(gca,'Location','SouthWest');
    set(gca,'TickDir','out','box','on')
    title('\delta^{18}O (source, after projection)')
    ylabel(['\delta^{18}O [',char(8240),']'])

    sp4=subplot(2,2,4);
    hold all
    for i=[1,3]
        qq = q & strcmp(T.Type,style{i}{7}); %select each sample type
        errorbar(datenum(T.time(qq)),T.mpH(qq),T.stdpH(qq),... 
            style{i}{1},'LineStyle',style{i}{2},'MarkerSize',style{i}{3},'Color',style{i}{6},...
            'DisplayName',style{i}{7})
    end
    xlim(xd)
    ylim(ydH2)
    datetick('x','keeplimits')
    %legend(gca,'Location','SouthWest');
    set(gca,'TickDir','out','box','on')
    title('\delta^{2}H (source, after projection)')
    ylabel(['\delta^{2}H [',char(8240),']'])

    %linkaxes([sp1,sp2,sp3,sp4],'x');

end

% 2 - FIGURE with focus on a period
if flag_plotdetail == 1
    dateint={'13-Jun-2018 12:00','27-Jun-2018 18:00'};
    xd=[datenum(dateint{1}),datenum(dateint{2})]; %xlimits for the plot
    q = T.time>=datetime(dateint{1}) & T.time<=datetime(dateint{2}); %some initial query
    xtck=xd(1):1:xd(end);

    figure
    set(gcf,'Units','centimeters','Position',[5 5 25 7])

    subplot(1,2,1)
    hold all
    for i=[1,3]
        qq = q & strcmp(T.Type,style{i}{7}); %select each sample type
        errorbar(datenum(T.time(qq)),T.mpO(qq),T.stdpO(qq),... 
            style{i}{1},'LineStyle',style{i}{2},'MarkerSize',style{i}{3},'Color',style{i}{6},...
            'DisplayName',style{i}{7})
    end
    xlim(xd)
    ylim(ydO2)
    %legend(gca,'Location','SouthWest');
    %set(gca,'TickDir','out','box','on','XTick',xtck,'XTickLabel',datestr(xtck','HH:MM'))
    set(gca,'TickDir','out','box','on','XMinorTick','on')
    datetick('x','keeplimits')
    title(sprintf('detail: %s to %s \\delta^{18}O',dateint{1}(1:6),dateint{2}(1:6)))
    %grid on
    ylabel(['\delta^{18}O [',char(8240),'] source'])

    subplot(1,2,2)
    hold all
    for i=[1,3]
        qq = q & strcmp(T.Type,style{i}{7}); %select each sample type
        errorbar(datenum(T.time(qq)),T.mpH(qq),T.stdpH(qq),... 
            style{i}{1},'LineStyle',style{i}{2},'MarkerSize',style{i}{3},'Color',style{i}{6},...
            'DisplayName',style{i}{7})
    end
    xlim(xd)
    ylim(ydH2)
    %legend(gca,'Location','SouthWest');
    %set(gca,'TickDir','out','box','on','XTick',xtck,'XTickLabel',datestr(xtck','HH:MM'))
    set(gca,'TickDir','out','box','on','XMinorTick','on')
    datetick('x','keeplimits')
    title(sprintf('detail: %s to %s \\delta^{2}H',dateint{1}(1:6),dateint{2}(1:6)))
    %grid on
    ylabel(['\delta^{2}H [',char(8240),'] source'])

end


% 3 - FIGURE with dual isotope plot
if flag_plotdualisotope == 1

    % additional figures with dual isotopes
    figure
    hold all
    plot([min(xinterval),max(xinterval)],[lmwl(1),lmwl(end)],'--','LineWidth',1,'Color',[0 0 0],...
        'DisplayName','LMWL');

    % first plot the range of evaporation lines
    tmp=find(T.time>datetime('28-May-2018'),1,'first'); %select period when all sample types are available
    for j=tmp:size(T,1)
        % set the appropriate colors
        switch T.Type{j}
            case 'Xylem'
                col = [1 .7 .4];
            case 'Leaves'
                col = [.9 .9 .9];
        end

    %     plot([T.d18O(j),T.mpO(j)],[T.d2H(j),T.mpH(j)],... %mean
    %         '-','Color',col,'HandleVisibility','off')
        plot([T.d18O(j),T.mpO(j)+T.stdpO(j)],[T.d2H(j),T.mpH(j)+T.stdpH(j)],... %mean+std
            '-','Color',col,'HandleVisibility','off')
         plot([T.d18O(j),T.mpO(j)-T.stdpO(j)],[T.d2H(j),T.mpH(j)-T.stdpH(j)],... %mean-std
            '-','Color',col,'HandleVisibility','off')
    end

    % plot measurements
    q = T.time>datetime('28-May-2018');
    for i=[1,3] %skip phloem for now
        qq = q & strcmp(T.Type,style{i}{7}); %select each sample type
        plot(datenum(T.d18O(qq)),T.d2H(qq),... 
            style{i}{1},'LineStyle','none','MarkerSize',style{i}{3},'Color',style{i}{6},...
            'DisplayName',style{i}{7})
    end

    % finish the plot    
    axis([-14 16 -100 0])
    axis([-15 12 -100 -10])
    title('\bf illustrated projection trajectories','FontSize',12)
    xlabel(['\delta^{18}O [',char(8240),']'])
    ylabel(['\delta^{2}H [',char(8240),']'])
    legend(gca,'Location','NW')
    box on
    axis square
    set(gca,'TickDir','out')

end


