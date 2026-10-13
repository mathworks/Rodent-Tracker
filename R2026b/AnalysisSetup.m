classdef AnalysisSetup < matlab.apps.App

    % Used to locate and load the app's XML configuration file
    properties (Access = public, Constant)
        AppConfigFilename = './AnalysisSetup.xml'; % File path to the app configuration file containing component layout and settings
    end

    % Properties that correspond to app components
    properties (Access = public)
        AnalysisVideoSettingsUIFigure   matlab.ui.Figure
        TraceFilenameEditField          matlab.ui.control.EditField
        TraceFilenameEditFieldLabel     matlab.ui.control.Label
        TrackerFilenameEditField        matlab.ui.control.EditField
        TrackerFilenameEditFieldLabel   matlab.ui.control.Label
        FPSEditField_Tracker            matlab.ui.control.NumericEditField
        FPSEditField_Tracker_Label      matlab.ui.control.Label
        FPSEditField_Trace              matlab.ui.control.NumericEditField
        FPSEditField_Trace_Label        matlab.ui.control.Label
        AnalyzeButton                   matlab.ui.control.Button
        TrackerVideoSaveDirectoryLabel  matlab.ui.control.Label
        TraceVideoSaveDirectoryLabel    matlab.ui.control.Label
        SaveDir_Trace                   matlab.ui.control.Button
        SaveDir_Tracker                 matlab.ui.control.Button
        SaveDirectoryTrace              matlab.ui.control.EditField
        SaveDirectoryTracker            matlab.ui.control.EditField
        SaveTraceVideoCheckBox          matlab.ui.control.CheckBox
        SaveTrackerVideoCheckBox        matlab.ui.control.CheckBox
    end

    % Callbacks that handle component events
    methods

        % Code that executes after component creation
        function startupFcn(app)
            app.AnalysisVideoSettingsUIFigure.Units = 'normalized';
            app.AnalysisVideoSettingsUIFigure.Position(1) = 0.40;
            app.AnalysisVideoSettingsUIFigure.Position(2) = 0.40;
            app.AnalysisVideoSettingsUIFigure.Units = 'pixels';
        end

        % Button pushed function: SaveDir_Tracker
        function SaveDir_TrackerButtonPushed(app, event)
            savedir_ap = uigetdir;
            app.SaveDirectoryTracker.Value = savedir_ap;
            app.SaveDirectoryTracker.Editable = 'on';
            figure(app.AnalysisVideoSettingsUIFigure)
            app.SaveTrackerVideoCheckBox.Value = 1;
        end

        % Button pushed function: SaveDir_Trace
        function SaveDir_TraceButtonPushed(app, event)
            savedir_ap = uigetdir;
            app.SaveDirectoryTrace.Value = savedir_ap;
            app.SaveDirectoryTrace.Editable = 'on';
            figure(app.AnalysisVideoSettingsUIFigure)
            app.SaveTraceVideoCheckBox.Value = 1;
        end

        % Value changed function: SaveTrackerVideoCheckBox
        function SaveTrackerVideoCheckBoxValueChanged(app, event)
            if app.SaveTrackerVideoCheckBox.Value == 1
                saveap = app.SaveTrackerVideoCheckBox.Value;
                app.SaveDirectoryTracker.Editable = 'on';
                app.FPSEditField_Tracker_Label.Enable ='on';
                app.FPSEditField_Tracker.Enable = 'on';
                app.TrackerFilenameEditField.Enable = 'on';
                app.TrackerFilenameEditFieldLabel.Enable = 'on';
            else
                saveap = app.SaveTrackerVideoCheckBox.Value;
                app.SaveDirectoryTracker.Editable = 'off';
                app.FPSEditField_Tracker_Label.Enable ='off';
                app.FPSEditField_Tracker.Enable = 'off';
                app.TrackerFilenameEditField.Enable = 'off';
                app.TrackerFilenameEditFieldLabel.Enable = 'off';
            end
        end

        % Value changed function: SaveTraceVideoCheckBox
        function SaveTraceVideoCheckBoxValueChanged(app, event)
            if app.SaveTraceVideoCheckBox.Value == 1
                savetr = app.SaveTraceVideoCheckBox.Value;
                app.SaveDirectoryTrace.Editable = 'on';
                app.FPSEditField_Trace_Label.Enable ='on';
                app.FPSEditField_Trace.Enable = 'on';
                app.TraceFilenameEditField.Enable = 'on';
                app.TraceFilenameEditFieldLabel.Enable = 'on';
            else
                savetr = app.SaveTraceVideoCheckBox.Value;
                app.SaveDirectoryTrace.Editable = 'off';
                app.FPSEditField_Trace_Label.Enable ='off';
                app.FPSEditField_Trace.Enable = 'off';
                app.TraceFilenameEditField.Enable = 'off';
                app.TraceFilenameEditFieldLabel.Enable = 'off';
            end
        end

        % Button pushed function: AnalyzeButton
        function AnalyzeButtonPushed(app, event)
            uiresume(app.AnalysisVideoSettingsUIFigure)
            app.AnalysisVideoSettingsUIFigure.Visible = 'off';
        end
    end

    % App creation
    methods (Access = public)

        % Construct app
        function app = AnalysisSetup(varargin)
            app = app@matlab.apps.App(varargin{:});

            if nargout == 0
                clear app
            end
        end
    end
end