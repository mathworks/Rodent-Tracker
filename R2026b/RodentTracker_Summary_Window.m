classdef RodentTracker_Summary_Window < matlab.apps.App

    % Used to locate and load the app's XML configuration file
    properties (Access = public, Constant)
        AppConfigFilename = './RodentTracker_Summary_Window.xml'; % File path to the app configuration file containing component layout and settings
    end

    % Properties that correspond to app components
    properties (Access = public)
        RodentTrackerSummaryUIFigure    matlab.ui.Figure
        FilenameLabel                   matlab.ui.control.Label
        TimeSpentLabel                  matlab.ui.control.Label
        SpeedunitsLabel                 matlab.ui.control.Label
        EccentricityLabel               matlab.ui.control.Label
        NumberofExitsLabel              matlab.ui.control.Label
        NumberofEntriesLabel            matlab.ui.control.Label
        TimeSpentsLabel                 matlab.ui.control.Label
    end

    properties (Access = private)
        Callingapp
    end

    % Callbacks that handle component events
    methods

        % Code that executes after component creation
        function startupFcn(app, Mainapp)
            %Position
            screen = get(0,'screensize');
            xres = screen(3)-screen(1);
            yres = screen(4)-screen(2);

            %Position
            app.RodentTrackerAnalysisPreviewUIFigure.Units = 'normalized';
            app.RodentTrackerAnalysisPreviewUIFigure.Position = [0.3 0.3 .3*(yres/xres) 0.3];%
            app.RodentTrackerAnalysisPreviewUIFigure.Units = 'pixels';

            app.Callingapp = Mainapp;

            app.FilenameLabel.Text = ['Filename: ' app.Callingapp.DropDown.Value];
            app.TimeSpentLabel.Text = ['Time Spent (%): ' num2str(app.Callingapp.t2.PercentageSpent_ROI)];
            app.SpeedunitsLabel.Text = ['Speed (' 'm' '/s): ' num2str(mean(app.Callingapp.t.Speed)) ' +/- ' num2str(std(app.Callingapp.t.Speed))];
            app.EccentricityLabel.Text = ['Eccentricity: ' num2str(mean(app.Callingapp.t.Eccentricity)) ' +/- ' num2str(std(app.Callingapp.t.Eccentricity))];
            app.NumberofExitsLabel.Text = ['Number of Exits: ' num2str(app.Callingapp.t2.Number_Entries)];
            app.NumberofEntriesLabel.Text = ['Number of Entries: ' num2str(app.Callingapp.t2.Number_Exits)];
            app.TimeSpentsLabel.Text = ['Time Spent (s): ' num2str(app.Callingapp.t2.TimeSpent_ROI)];
        end
    end

    % App creation
    methods (Access = public)

        % Construct app
        function app = RodentTracker_Summary_Window(varargin)
            app = app@matlab.apps.App(varargin{:});

            if nargout == 0
                clear app
            end
        end
    end
end