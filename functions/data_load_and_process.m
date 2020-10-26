function T = data_load_and_process

% some general settings
tstart = datetime('08-May-2018'); %time after which xylem samples were collected
data_reload = 0; %to reload isotope data from the repository

% load isotope data from the zenodo repository
filename = 'data\data_SPIKE_II.csv';
if ~isfile(filename) || data_reload == 1
    url = 'https://zenodo.org/record/4037240/files/spike.isotope.II.csv';
    filename = 'data\data_SPIKE_II.csv';
    websave(filename,url);
end

% load plant isotope data into a table and select the variables of interest
filename = 'data_plant_isotopes_SPIKE_II.csv';
T=readtable(filename);
%T.Properties.VariableNames{'TIMESTAMP'} = 'time'; %rename the column
%q = T.time>tstart & ~cellfun('isempty',regexp(T.Type,('Xylem|Leaf'))); %query
q = T.time>tstart & ~cellfun('isempty',regexp(T.type,('Xylem|Leaves'))); %query
T = T(q,:);

% load meteo data
filename = 'meteodata_EPFL.csv';
data = readtable(filename,'HeaderLines',4);

% filename = 'meteoEPFL_data.dat';
% fid=fopen(filename);
% hdlines=1;
% delim='\t';
% emptval=NaN;
% treatsempty='NA';
% formt='%25s %14.0f %14.2f %14.2f %14.2f %14.2f %14.2f %14.2f %14.2f %14.2f %14.2f %14.0f\r\n';
% A=textscan(fid,formt,'Delimiter',delim,'HeaderLines',hdlines,...
%     'TreatAsEmpty',treatsempty,'EmptyValue',emptval,'EndOfLine','\r\n');
% fclose(fid);
% data.time=datenum(A{1},'yyyy-mm-dd HH:MM');
% data.T=A{11}; data.rh=A{12};

% clean and prepare the data
%remove a contaminated sample 
T(T.time=='23-Jun-2018 10:10:00',:)=[]; %this was influenced by the previous mushroom measurement

% create an index to tell whether measurements refer to the same sampling
% time (useful to identify replicate samples)
diffthresh=1; %[hours] maximum difference allowed to consider two dates as one single date
[tmpval,tmpind]=sort(T.time,'ascend');
isuni=diff(tmpval)>diffthresh/24; %this checks if the samples are unique (within the given tolerance)
icsorted=cumsum([1;isuni]); %count the unique values
T.datecount=icsorted(tmpind); %give the same ordering as the original T.time vector 

% add meteo data to the table. Take an average during "delt" days prior to sample
delt1=24/24; %delta [days] prior to sampling date (shorter interval, hours to days)
delt2=30; %delta [days] prior to sampling date (longer interval, weeks to months)
T.Tday=zeros(size(T,1),1); %preallocate
T.rhday=zeros(size(T,1),1);
T.Tmonth=zeros(size(T,1),1);
T.rhmonth=zeros(size(T,1),1);
for i=1:size(T,1)
    q = data.time >= T.time(i)-delt1 & data.time <= T.time(i);
    T.Tday(i)=mean(data.T(q));
    T.rhday(i)=mean(data.rh(q));
    q = data.time >= T.time(i)-delt2 & data.time <= T.time(i);
    T.Tmonth(i)=mean(data.T(q));
    T.rhmonth(i)=mean(data.rh(q));
end

end

