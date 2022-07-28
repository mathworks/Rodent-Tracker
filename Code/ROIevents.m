function ROIevents(app,evt)
evname = evt.EventName;
switch(evname)
    case{'MovingROI'}
%         disp(['ROI moving previous position: ' mat2str(evt.PreviousPosition)]);
%         disp(['ROI moving current position: ' mat2str(evt.CurrentPosition)]);
% app.Parent.Parent.Children(2).Data(str2num(app.Tag),6:9) = evt.CurrentPosition;
        Table = findall(app.Parent.Parent.Children,'Type','uitable');
        Table.Data(str2num(app.Tag),6:9) = evt.CurrentPosition;
    case{'ROIMoved'}
%         disp(['ROI moved previous position: ' mat2str(evt.PreviousPosition)]);
%         disp(['ROI moved current position: ' mat2str(evt.CurrentPosition)]);
        Table = findall(app.Parent.Parent.Children,'Type','uitable');
        Table.Data(str2num(app.Tag),6:9) = evt.CurrentPosition;
%         end+1-str2num(app.Tag)
end
end