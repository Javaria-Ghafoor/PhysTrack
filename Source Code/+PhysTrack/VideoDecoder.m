function VideoDecoder(fileName, saveName)
% This function simply converts a compressed video to raw AVI. When using a
% compressed video, the whole process is slowed down because of the way
% video reading functino works. To fetch any frame N in a video sequence,
% the video reader function has to convert all the preceding frames first
% because in a compressed video, no frame is independent  of its previous
% frames. This is resolved by converting the whole video into raw AVI which
% stores a BitmapImage for every frame, independent  of the history. This
% could have been done on the RAM but for bigger vidfeo, the memory
% requirements are so enormous that its better to wait for the video
% conversion than to fill the whole RAM space with giant Bitmap data
% arrays.
%
%    Example
%    PhysTrack.VideoDecoder;
%    Presents a file selection and save dialogue to decide the source and
%    destination files and converts the video to RAW while showing the
%    progress in a waitbar.

    if nargin == 0
    [fileName, pathname] = uigetfile({ ...
        '*.mp4;*.mov;*.mpg;*.avi', 'Common Video File Types (*.mp4,*.mov,*.mpg,*.avi)';...
        '*.*', 'All Files';...
        },'Select a video file for conversion.');
        fileName = [pathname, fileName];
    end
    if nargin < 2
        [saveName, pathname] = uiputfile({ ...
        '*.avi', 'Uncompressed AVI (*.avi)';...
        '*.*', 'All Files';...
        },'Select a destination for saving the decompressed video');
        saveName = [pathname, saveName];
    end
    
    skippedValue = double(round(PhysTrack.askValue('Kindly enter the number of frames to be skipped after every decoded frame.', 0.0))) + 1;
    newFPS = double(round(PhysTrack.askValue('What should be the frame rate of the decoded vide while playing.', vro.FrameRate/skippedValue))) + 1;
    vro = VideoReader(fileName);
    vfr = vision.VideoFileReader(fileName);
    vwo = VideoWriter(saveName);
    vwo.FrameRate = newFPS;
    open(vwo);
    h = waitbar(0, '');
    for ii = 1:skippedValue:vro.NumberOfFrames
        writeVideo(vwo, step(vfr));
        waitbar(ii / double(vro.NumberOfFrames), h, ...
            ['Converted frame ',num2str(ii), ' of ', num2str(vro.NumberOfFrames), ', (',num2str(round(ii / double(vro.NumberOfFrames) * double(100))), '%)']);
    end
    close(h);
end

