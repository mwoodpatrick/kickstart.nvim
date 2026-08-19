return function()
  require('vim._core.ui2').enable {
    enable = true,
    msg = {
      targets = 'cmd', -- Route messages through the modernized command area
      pager = {
        height = 1, -- Configure pager behavior for long outputs
      },
    },
    transparency = true,
  }
end
