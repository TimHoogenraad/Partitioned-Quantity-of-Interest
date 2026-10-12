function profile = loadChannelProfile(filePath)
%LOADCHANNELPROFILE Load a minimal-channel time-averaged profile file.
%   The 10-column DNS, 13-column full LES, and 6-column reduced LES formats
%   are supported.

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

columnCount = size(data, 2);
if ~ismember(columnCount, [6 10 13])
    error('pqoi:InvalidChannelDataset', ...
        'Expected a 6-, 10-, or 13-column channel profile.');
end

profile = struct();
profile.label = char(filePath);
profile.coordinate = data(:,1);
profile.metadata = struct( ...
    'averagingTime', header(1), ...
    'frictionReynoldsNumber', header(2), ...
    'frictionVelocity', header(3), ...
    'kinematicViscosity', header(4), ...
    'wallShearStress', header(5), ...
    'gridSize', header(7:9), ...
    'simulationStep', header(10));

flow = struct();
flow.meanU = data(:,2);
flow.meanV = data(:,3);
flow.nu = header(4);

if columnCount == 6
    profile.kind = 'LES';
    profile.format = 'reduced';
    flow.meanUV = data(:,4);
    flow.tauSgs = data(:,5);
    flow.dUdy = data(:,6);
elseif columnCount == 10
    profile.kind = 'DNS';
    profile.format = 'full';
    flow.meanW = data(:,4);
    flow.meanU2 = data(:,5);
    flow.meanV2 = data(:,6);
    flow.meanW2 = data(:,7);
    flow.meanUV = data(:,8);
    flow.dUdy = data(:,9);
    flow.residualDissipation = data(:,10);
else
    profile.kind = 'LES';
    profile.format = 'full';
    flow.meanW = data(:,4);
    flow.meanU2 = data(:,5);
    flow.meanV2 = data(:,6);
    flow.meanW2 = data(:,7);
    flow.meanUV = data(:,8);
    flow.tauSgs = data(:,9);
    flow.dUdy = data(:,10);
    flow.nuSgs = data(:,11);
    flow.sgsDissipation = data(:,12);
    flow.residualDissipation = data(:,13);
end

profile.data = flow;
profile.profiles.totalShearStress = ...
    pqoi.qoi.channel.totalShearStress(flow);
profile.profiles.production = pqoi.qoi.channel.production(flow);
if all(isfield(flow, {'meanU2','meanV2','meanW2'}))
    profile.profiles.turbulentKineticEnergy = ...
        pqoi.qoi.channel.turbulentKineticEnergy(flow);
end
profile.columns = columnNames;
end
