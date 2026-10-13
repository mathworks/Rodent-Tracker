function app = startRodentTracker(format)
%startRodentTracker - Launch the repository copy of Rodent Tracker
%   APP = startRodentTracker launches the M-file app on MATLAB R2026b or
%   newer, and the original MLAPP app on earlier releases. APP is the
%   main app object. Image Processing Toolbox is required.
%
%   APP = startRodentTracker(FORMAT) selects the source format. FORMAT is:
%       "auto"  - (default) Selects the format for the MATLAB release.
%       "m"     - Selects the M-file app; requires MATLAB R2026b or newer.
%       "mlapp" - Selects the original app in the Code folder.
%
%   The launcher adds repository folders to the MATLAB path for this
%   session. It sets the current folder to R2026b for the M-file app or to
%   the repository root for the original app. Close Rodent Tracker and
%   restart MATLAB before switching formats or copies of the app.
%
%   See also RodentTracker, addpath, cd

if nargin == 0
    format = 'auto';
end
format = validatestring(format, {'auto', 'm', 'mlapp'}, ...
    mfilename, 'format', 1);

hasNativeAppSupport = ~isMATLABReleaseOlderThan('R2026b');
if strcmp(format, 'auto')
    if hasNativeAppSupport
        format = 'm';
    else
        format = 'mlapp';
    end
elseif strcmp(format, 'm') && ~hasNativeAppSupport
    error('RodentTracker:UnsupportedRelease', ...
        'The M-file app requires MATLAB R2026b or newer. Use "mlapp".');
end

repoFolder = fileparts(mfilename('fullpath'));
resourceFolder = fullfile(repoFolder, 'Rodent Tracker_resources');
if strcmp(format, 'm')
    appFolder = fullfile(repoFolder, 'R2026b');
    launchFolder = appFolder;
else
    appFolder = fullfile(repoFolder, 'Code');
    launchFolder = repoFolder;
end

appNames = {'RodentTracker', 'AnalysisSetup', ...
    'RodentTracker_Background_Window', 'RodentTracker_ROI_Window', ...
    'RodentTracker_ROI_Results_Window', 'RodentTracker_SAP_Window', ...
    'RodentTracker_Spreadsheet_Window', 'RodentTracker_Summary_Window', ...
    'RodentTracker_Trace_Window', 'RodentTracker_Video_Window'};
for index = 1:numel(appNames)
    appFile = fullfile(appFolder, [appNames{index} '.' format]);
    if ~isfile(appFile)
        error('RodentTracker:IncompleteDownload', ...
            'Missing app file: %s. Download the complete repository.', ...
            appFile);
    end
end
if ~isfolder(resourceFolder)
    error('RodentTracker:MissingResources', ...
        'Missing resource folder: %s.', resourceFolder);
end
if isempty(ver('images'))
    error('RodentTracker:MissingToolbox', ...
        'Rodent Tracker requires Image Processing Toolbox.');
end

loadedFiles = inmem('-completenames');
for index = 1:numel(loadedFiles)
    [loadedFolder, loadedName] = fileparts(loadedFiles{index});
    if ismember(loadedName, appNames) && ~isempty(loadedFolder) && ...
            ~sameFolder(loadedFolder, appFolder)
        error('RodentTracker:LoadedCopyConflict', ...
            ['Another copy of %s is loaded from %s. Close Rodent Tracker ' ...
            'and restart MATLAB before changing app copies or formats.'], ...
            loadedName, loadedFolder);
    end
end

previousFolder = pwd;
previousPath = path;
try
    cd(launchFolder)
    addpath(repoFolder, resourceFolder, appFolder, '-begin')
    for index = 1:numel(appNames)
        resolvedFile = which(appNames{index});
        [resolvedFolder, ~, resolvedExtension] = fileparts(resolvedFile);
        if ~sameFolder(resolvedFolder, appFolder) || ...
                ~strcmp(resolvedExtension, ['.' format])
            error('RodentTracker:PathConflict', ...
                ['MATLAB resolves %s to %s instead of %s. Close the app ' ...
                'and restart MATLAB, then launch from this repository.'], ...
                appNames{index}, resolvedFile, appFolder);
        end
    end
    app = RodentTracker;
catch exception
    path(previousPath)
    cd(previousFolder)
    rethrow(exception)
end
end

function tf = sameFolder(firstFolder, secondFolder)
%sameFolder - Compare folder paths with platform-appropriate case rules
if ispc
    tf = strcmpi(firstFolder, secondFolder);
else
    tf = strcmp(firstFolder, secondFolder);
end
end
