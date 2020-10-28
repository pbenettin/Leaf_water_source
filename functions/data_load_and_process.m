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
filename = 'temp_spike.isotope.II.csv';
T=readtable(filename);

% simplify the naming
T.Properties.VariableNames{'TIMESTAMP'} = 'time';
T.Properties.VariableNames{'d18O_UoS'} = 'd18O';
T.Properties.VariableNames{'d2H_UoS'} = 'd2H';
T.Type(~cellfun('isempty',regexp(T.Type,('Xylem'))),:) = {'Xylem'};

% simplify the data: select a few columns and xylem and leaf data only
q = T.time>tstart & (strcmp(T.Type,'Xylem') | strcmp(T.Type,'Leaves')); %query
T = T(q,{'Type','time','d18O','d2H'});

% load meteo data
filename = 'meteodata_EPFL.csv';
data = readtable(filename,'HeaderLines',4);

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

