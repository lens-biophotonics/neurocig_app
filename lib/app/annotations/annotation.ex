defmodule App.Annotations.Annotation do
  alias App.Videos.Video

  defstruct video: %Video{},
            frame: nil,
            mouse_id: nil,
            new_mouse_id: nil,
            bb_x1: nil,
            bb_y1: nil,
            bb_x2: nil,
            bb_y2: nil,
            nose_x: nil,
            nose_y: nil,
            earL_x: nil,
            earL_y: nil,
            earR_x: nil,
            earR_y: nil,
            tailB_x: nil,
            tailB_y: nil
end
