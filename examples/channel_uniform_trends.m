%% Recreate uniform channel pQoI error trends
clear;
root = fileparts(fileparts(mfilename('fullpath')));
addpath(root);

folder = fullfile(root, 'datasets', 'minimal_channel', 'uniform');
dns = pqoi.foldSymmetry(pqoi.io.loadChannelProfile( ...
    fullfile(folder, 'reference_dns.txt')));

intervalCounts = [8 16 32 64];
qoiNames = {'totalShearStress', 'turbulentKineticEnergy'};
partitionErrors = struct();
globalErrors = struct();

for q = 1:numel(qoiNames)
    partitionErrors.(qoiNames{q}) = zeros(numel(intervalCounts), 4);
    globalErrors.(qoiNames{q}) = zeros(numel(intervalCounts), 1);
end

for i = 1:numel(intervalCounts)
    pointCount = intervalCounts(i)+1;
    filename = sprintf('les_ny%03d.txt', pointCount);
    les = pqoi.foldSymmetry(pqoi.io.loadChannelProfile( ...
        fullfile(folder, filename)));

    intervalsPerPartition = (numel(les.coordinate)-1)/4;
    partitions = pqoi.makeGridPartitions( ...
        les.coordinate, intervalsPerPartition);
    comparison = pqoi.compare(dns, les, partitions, ...
        'Interpolation', 'linear');

    for q = 1:numel(qoiNames)
        name = qoiNames{q};
        partitionErrors.(name)(i,:) = comparison.profiles.(name).error;
        globalErrors.(name)(i) = comparison.profiles.(name).globalError/4;
    end
end

colors = [
    0.0000 0.4470 0.7410
    0.8500 0.3250 0.0980
    0.4940 0.1840 0.5560
    0.4700 0.6700 0.1900];
styles = {'-','--','-.',':'};
titles = {'$\tau_w$', '$E_{\mathrm{TKE}}$'};

figure('Theme', 'light', 'Color', 'white', ...
    'Units', 'inches', 'Position', [1 1 4.5 7]);
layout = tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
legendHandles = gobjects(5,1);
for q = 1:numel(qoiNames)
    axesHandle = nexttile(layout);
    hold(axesHandle, 'on');
    name = qoiNames{q};
    for p = 1:4
        lineHandle = semilogx(axesHandle, intervalCounts, ...
            partitionErrors.(name)(:,p), ...
            styles{p}, 'Color', colors(p,:), 'LineWidth', 1.5, ...
            'Marker', 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'white');
        if q == 1
            legendHandles(p) = lineHandle;
        end
    end
    globalHandle = semilogx(axesHandle, intervalCounts, ...
        globalErrors.(name), 'k--s', ...
        'LineWidth', 1.8, 'MarkerSize', 5);
    if q == 1
        legendHandles(5) = globalHandle;
    end
    grid(axesHandle, 'on');
    set(axesHandle, 'Color', 'white', 'XColor', 'black', 'YColor', 'black');
    title(axesHandle, titles{q}, 'Interpreter', 'latex');
    ylabel(axesHandle, '$e$ (\%)', 'Interpreter', 'latex');
    xticks(axesHandle, intervalCounts);
    xlim(axesHandle, [7 72]);
    if q == 1
        ylim(axesHandle, [0 9]);
    else
        ylim(axesHandle, [0 25]);
    end
    if q == 1
        axesHandle.XTickLabel = [];
    else
        xlabel(axesHandle, '$N$', 'Interpreter', 'latex');
    end
end

legendHandle = legend(legendHandles, ...
    {'$P_1$','$P_2$','$P_3$','$P_4$', ...
    '$e_{\mathrm{global}}/4$'}, 'Interpreter', 'latex', ...
    'Orientation', 'horizontal');
legendHandle.Layout.Tile = 'north';

outputFolder = fullfile(root, 'validation');
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end
outputPath = fullfile(outputFolder, 'channel_uniform_qoi_trends.png');
exportgraphics(gcf, outputPath, 'Resolution', 300);
fprintf('Saved %s\n', outputPath);
disp(partitionErrors);
disp(globalErrors);
