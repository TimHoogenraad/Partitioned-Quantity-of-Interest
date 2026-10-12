function profile = loadChannelProfile(filePath)
%LOADCHANNELPROFILE Load a minimal-channel time-averaged profile file.
%   Both the 10-column DNS format and 13-column LES format are supported.

fileID = fopen(filePath, 'r');
if fileID == -1
    error('pqoi:FileNotFound', 'Could not open profile file: %s', filePath);
end
cleanup = onCleanup(@() fclose(fileID));

fgetl(fileID);
headerLine = fgetl(fileID);
columnLine = fgetl(fileID);
header = sscanf(strrep(headerLine, '%', ''), '%f').';
columnNames = strsplit(strtrim(erase(columnLine, '%')));
data = textscan(fileID, repmat('%f', 1, numel(columnNames)), ...
    'CollectOutput', true);
data = data{1};

if size(data, 2) ~= 10 && size(data, 2) ~= 13
    error('pqoi:InvalidChannelDataset', ...
        'Expected a 10-column DNS or 13-column LES profile.');
end

profile = struct();
profile.label = char(filePath);
profile.coordinate = data(:,1);
profile.metadata = struct( ...
    'averagingTime', header(1), ...
    'frictionReynoldsNumber', header(2), ...
    'frictionVelocity', header(3), ...
    'kinematicViscosity', header(4), ...
    'wallShearStress', header(5));

flow = struct();
flow.meanU = data(:,2);
flow.meanV = data(:,3);
flow.meanW = data(:,4);
flow.meanU2 = data(:,5);
flow.meanV2 = data(:,6);
flow.meanW2 = data(:,7);
flow.meanUV = data(:,8);
flow.nu = header(4);

if size(data,2) == 10
    profile.kind = 'DNS';
    flow.dUdy = data(:,9);
    flow.residualDissipation = data(:,10);
else
    profile.kind = 'LES';
    flow.tauSgs = data(:,9);
    flow.dUdy = data(:,10);
    flow.nuSgs = data(:,11);
    flow.sgsDissipation = data(:,12);
    flow.residualDissipation = data(:,13);
end

profile.data = flow;
profile.profiles.totalShearStress = ...
    pqoi.qoi.channel.totalShearStress(flow);
profile.profiles.turbulentKineticEnergy = ...
    pqoi.qoi.channel.turbulentKineticEnergy(flow);
profile.profiles.production = pqoi.qoi.channel.production(flow);
profile.columns = columnNames;
end
