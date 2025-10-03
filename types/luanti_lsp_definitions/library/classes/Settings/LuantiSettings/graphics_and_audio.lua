---@meta _
-- DRAFT 1 DONE
-- builtin/settingtypes.txt
-- minetest.conf.example

-- Section context mapping:
-- * [Graphics and Audio]: [client]


-- -------------------- [Graphics and Audio] [*Graphics] -------------------- --

-- --------------- [Graphics and Audio] [*Graphics] [**Screen] -------------- --

---@class _.LuantiSettings.graphics_and_audio.graphics.screen
--[[
#    Width component of the initial window size.
#
#    Requires: desktop
[client]
(Screen width) 1024 1 65535
]]
---@field screen_w integer?
--[[
#    Height component of the initial window size.
#
#    Requires: desktop
[client]
(Screen height) 600 1 65535
]]
---@field screen_h integer?
--[[
#    Whether the window is maximized.
#
#    Requires: desktop
[client]
(Window maximized) false
]]
---@field window_maximized boolean?
--[[
#    Save window size automatically when modified.
#    If true, screen size is saved in screen_w and screen_h, and whether the window
#    is maximized is stored in window_maximized.
#    (Autosaving window_maximized only works if compiled with SDL.)
#
#    Requires: desktop
[client]
(Remember screen size) true
]]
---@field autosave_screensize boolean?
--[[
#    Fullscreen mode.
#
#    Requires: desktop
[client]
(Full screen) false
]]
---@field fullscreen boolean?
--[[
#    Open the pause menu when the window's focus is lost. Does not pause if a formspec is
#    open.
#
#    Requires: desktop
[client]
(Pause on lost window focus) false
]]
---@field pause_on_lost_focus boolean?

-- ---------------- [Graphics and Audio] [*Graphics] [**FPS] ---------------- --

---@class _.LuantiSettings.graphics_and_audio.graphics.fps
--[[
#    If FPS would go higher than this, limit it by sleeping
#    to not waste CPU power for no benefit.
[client]
(Maximum FPS) 60 1 4294967295
]]
---@field fps_max integer?
--[[
#    Vertical screen synchronization. Your system may still force VSync on even if this is disabled.
[client]
(VSync) false
]]
---@field vsync boolean?
--[[
#    Maximum FPS when the window is not focused.
[client]
(FPS when unfocused) 10 1 4294967295
]]
---@field fps_max_unfocused integer?
--[[
#    View distance in nodes.
[client]
(Viewing range) 190 20 4000
]]
---@field viewing_range integer?
--[[
#    Undersampling is similar to using a lower screen resolution, but it applies
#    to the game world only, keeping the GUI intact.
#    It should give a significant performance boost at the cost of less detailed image.
#    Higher values result in a less detailed image.
#    Note: Undersampling is currently not supported if the "3d_mode" setting is set
#    to a non-default value.
[client]
(Undersampling) 1 1 8
]]
---@field undersampling integer?

-- ----------------- [Graphics and Audio] [*Graphics] [**3D] ---------------- --

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.3d_mode
--- | "none"
--- | "anaglyph"
--- | "interlaced"
--- | "topbottom"
--- | "sidebyside"
--- | "crossview"

---@class _.LuantiSettings.graphics_and_audio.graphics.3d
--[[
#    3D support.
#    Currently supported:
#    -    none: no 3d output.
#    -    anaglyph: cyan/magenta color 3d.
#    -    interlaced: odd/even line based polarization screen support.
#    -    topbottom: split screen top/bottom.
#    -    sidebyside: split screen side by side.
#    -    crossview: Cross-eyed 3d
[client]
(3D mode) none none,anaglyph,interlaced,topbottom,sidebyside,crossview
]]
---@field ["3d_mode"] core.LuantiSettings.enums.3d_mode?
--[[
#    Strength of 3D mode parallax.
[client]
(3D mode parallax strength) 0.025 -0.087 0.087
]]
---@field ["3d_paralax_strength"] number?

-- -------------- [Graphics and Audio] [*Graphics] [**Bobbing] -------------- --

---@class _.LuantiSettings.graphics_and_audio.graphics.bobbing
--[[
#    Arm inertia, gives a more realistic movement of
#    the arm when the camera moves.
[client]
(Arm inertia) true
]]
---@field arm_inertia boolean?
--[[
#    Enable view bobbing and amount of view bobbing.
#    For example: 0 for no view bobbing; 1.0 for normal; 2.0 for double.
[client]
(View bobbing factor) 1.0 0.0 7.9
]]
---@field view_bobbing_amount number?

-- --------------- [Graphics and Audio] [*Graphics] [**Camera] -------------- --

---@class _.LuantiSettings.graphics_and_audio.graphics.camera
--[[
#    Field of view in degrees.
[client]
(Field of view) 72 45 160
]]
---@field fov integer?
--[[
#    Alters the light curve by applying 'gamma correction' to it.
#    Higher values make middle and lower light levels brighter.
#    Value '1.0' leaves the light curve unaltered.
#    This only has significant effect on daylight and artificial
#    light, it has very little effect on natural night light.
[client]
(Light curve gamma) 1.0 0.33 3.0
]]
---@field display_gamma number?
--[[
#    The strength (darkness) of node ambient-occlusion shading.
#    Lower is darker, Higher is lighter. The valid range of values for this
#    setting is 0.25 to 4.0 inclusive. If the value is out of range it will be
#    set to the nearest valid value.
[client]
(Ambient occlusion gamma) 1.8 0.25 4.0
]]
---@field ambient_occlusion_gamma number?

-- ------------ [Graphics and Audio] [*Graphics] [**Screenshots] ------------ --

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.screenshot_format
--- | "png"
--- | "jpg"

---@class _.LuantiSettings.graphics_and_audio.graphics.screenshots
--[[
#    Path to save screenshots at. Can be an absolute or relative path.
#    The folder will be created if it doesn't already exist.
#
#    Requires: desktop
[client]
(Screenshot folder) screenshots
]]
---@field screenshot_path core.LuantiSettings.path?
--[[
#    Format of screenshots.
#
#    Requires: desktop
[client]
(Screenshot format) png png,jpg
]]
---@field screenshot_format core.LuantiSettings.enums.screenshot_format?
--[[
#    Screenshot quality. Only used for JPEG format.
#    1 means worst quality; 100 means best quality.
#    Use 0 for default quality.
#
#    Requires: desktop
[client]
(Screenshot quality) 0 0 100
]]
---@field screenshot_quality integer?

-- ---- [Graphics and Audio] [*Graphics] [**Node and Entity Highlighting] --- --

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.node_highlighting
--- | "box"
--- | "halo"
--- | "none"

---@class _.LuantiSettings.graphics_and_audio.graphics.node_and_entity_highlighting
--[[
#    Method used to highlight selected object.
[client]
(Node highlighting) box box,halo,none
]]
---@field node_highlighting core.LuantiSettings.enums.node_highlighting?
--[[
#    Show entity selection boxes
#    A restart is required after changing this.
[client]
(Show entity selection boxes) false
]]
---@field show_entity_selectionbox boolean?
--[[
#    Selection box border color (R,G,B).
[client]
(Selection box color) (0,0,0)
]]
---@field selectionbox_color string?
--[[
#    Width of the selection box lines around nodes.
[client]
(Selection box width) 2 1 5
]]
---@field selectionbox_width integer?
--[[
#    Crosshair color (R,G,B).
#    Also controls the object crosshair color
[client]
(Crosshair color) (255,255,255)
]]
---@field crosshair_color string?
--[[
#    Crosshair alpha (opaqueness, between 0 and 255).
#    This also applies to the object crosshair.
[client]
(Crosshair alpha) 255 0 255
]]
---@field crosshair_alpha integer?

-- ---------------- [Graphics and Audio] [*Graphics] [**Fog] ---------------- --

---@class _.LuantiSettings.graphics_and_audio.graphics.fog
--[[
#    Whether to fog out the end of the visible area.
[client]
(Fog) true
]]
---@field enable_fog boolean?
--[[
#    Make fog and sky colors depend on daytime (dawn/sunset) and view direction.
#
#    Requires: enable_fog
[client]
(Colored fog) true
]]
---@field directional_colored_fog boolean?
--[[
#    Fraction of the visible distance at which fog starts to be rendered
#
#    Requires: enable_fog
[client]
(Fog start) 0.4 0.0 0.99
]]
---@field fog_start number?

-- --------------- [Graphics and Audio] [*Graphics] [**Clouds] -------------- --

---@class _.LuantiSettings.graphics_and_audio.graphics.clouds
--[[
#    Allow clouds to look 3D instead of flat.
[client]
(3D clouds) true
]]
---@field enable_3d_clouds boolean?
--[[
#   Use smooth cloud shading.
#
#   Requires: enable_3d_clouds
[client]
(Soft clouds) false
]]
---@field soft_clouds boolean?

-- ----- [Graphics and Audio] [*Graphics] [**Filtering and Antialiasing] ---- --

---@class _.LuantiSettings.graphics_and_audio.graphics.filtering_and_antialiasing
--[[
#    Use mipmaps when scaling textures. May slightly increase performance,
#    especially when using a high-resolution texture pack.
#    Gamma-correct downscaling is not supported.
[client]
(Mipmapping) false
]]
---@field mip_map boolean?
--[[
#    Use bilinear filtering when scaling textures.
[client]
(Bilinear filtering) false
]]
---@field bilinear_filter boolean?
--[[
#    Use trilinear filtering when scaling textures.
#    If both bilinear and trilinear filtering are enabled, trilinear filtering
#    is applied.
[client]
(Trilinear filtering) false
]]
---@field trilinear_filter boolean?
--[[
#    Use anisotropic filtering when looking at textures from an angle.
#    This provides a significant improvement when used together with mipmapping.
[client]
(Anisotropic filtering) false
]]
---@field anisotropic_filter boolean?

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.antialiasing
--- | "none"
--- | "fsaa"
--- | "fxaa"
--- | "ssaa"

---@class _.LuantiSettings.graphics_and_audio.graphics.filtering_and_antialiasing
--[[
#    Select the antialiasing method to apply.
#
#    * None - No antialiasing (default)
#
#    * FSAA - Hardware-provided full-screen antialiasing
#             A.K.A multi-sample antialiasing (MSAA)
#             Smoothens out block edges but does not affect the insides of textures.
#
#             If Post Processing is disabled, changing FSAA requires a restart.
#             Also, if Post Processing is disabled, FSAA will not work together with
#             undersampling or a non-default "3d_mode" setting.
#
#    * FXAA - Fast approximate antialiasing
#             Applies a post-processing filter to detect and smoothen high-contrast edges.
#             Provides balance between speed and image quality.
#
#    * SSAA - Super-sampling antialiasing
#             Renders higher-resolution image of the scene, then scales down to reduce
#             the aliasing effects. This is the slowest and the most accurate method.
[client]
(Antialiasing method) none none,fsaa,fxaa,ssaa
]]
---@field antialiasing core.LuantiSettings.enums.antialiasing?

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.fsaa
--- | "2"
--- | "4"
--- | "8"
--- | "16"

---@class _.LuantiSettings.graphics_and_audio.graphics.filtering_and_antialiasing
--[[
#    Defines the size of the sampling grid for FSAA and SSAA antialiasing methods.
#    Value of 2 means taking 2x2 = 4 samples.
[client]
(Anti-aliasing scale) 2 2,4,8,16
]]
---@field fsaa core.LuantiSettings.enums.fsaa?

-- --------- [Graphics and Audio] [*Graphics] [**Occlusion Culling] --------- --

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.occlusion_culler
--- | "bfs"
--- | "loops"

--[[
WIPDOC
]]
---@class _.LuantiSettings.graphics_and_audio.graphics.occlusion_culling
--[[
#    Type of occlusion_culler
#
#    "loops" is the legacy algorithm with nested loops and O(n³) complexity
#    "bfs" is the new algorithm based on breadth-first-search and side culling
#
#    This setting should only be changed if you have performance problems.
[client]
(Occlusion Culler) bfs bfs,loops
]]
---@field occlusion_culler core.LuantiSettings.enums.occlusion_culler?
--[[
#    Use raytraced occlusion culling in the new culler.
#	 This flag enables use of raytraced occlusion culling test for
#    client mesh sizes smaller than 4x4x4 map blocks.
[client]
(Enable Raytraced Culling) true
]]
---@field enable_raytraced_culling boolean?

-- --------------------- [Graphics and Audio] [*Effects] -------------------- --

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.leaves_style
--- | "fancy"
--- | "simple"
--- | "opaque"

--[[
WIPDOC
]]
---@class _.LuantiSettings.graphics_and_audio.effects
--[[
#    Allows liquids to be translucent.
[client]
(Translucent liquids) true
]]
---@field translucent_liquids boolean?
--[[
#    Leaves style:
#    -   Fancy:  all faces visible
#    -   Simple: only outer faces
#    -   Opaque: disable transparency
[client]
(Leaves style) fancy fancy,simple,opaque
]]
---@field leaves_style core.LuantiSettings.enums.leaves_style?
--[[
#    Connects glass if supported by node.
[client]
(Connect glass) false
]]
---@field connected_glass boolean?
--[[
#    Enable smooth lighting with simple ambient occlusion.
[client]
(Smooth lighting) true
]]
---@field smooth_lighting boolean?
--[[
#    Enables tradeoffs that reduce CPU load or increase rendering performance
#    at the expense of minor visual glitches that do not impact game playability.
[client]
(Tradeoffs for performance) false
]]
---@field performance_tradeoffs boolean?


-- ------------ [Graphics and Audio] [*Effects] [**Waving Nodes] ------------ --


--[[
WIPDOC
]]
---@class _.LuantiSettings.graphics_and_audio.effects.waving_nodes
--[[
#    Set to true to enable waving leaves.
[client]
(Waving leaves) false
]]
---@field enable_waving_leaves boolean?
--[[
#    Set to true to enable waving plants.
[client]
(Waving plants) false
]]
---@field enable_waving_plants boolean?
--[[
#    Set to true to enable waving liquids (like water).
[client]
(Waving liquids) false
]]
---@field enable_waving_water boolean?
--[[
#    The maximum height of the surface of waving liquids.
#    4.0 = Wave height is two nodes.
#    0.0 = Wave doesn't move at all.
#    Default is 1.0 (1/2 node).
#
#    Requires: enable_waving_water
[client]
(Waving liquids wave height) 1.0 0.0 4.0
]]
---@field water_wave_height number?
--[[
#    Length of liquid waves.
#
#    Requires: enable_waving_water
[client]
(Waving liquids wavelength) 20.0 0.1
]]
---@field water_wave_length number?
--[[
#    How fast liquid waves will move. Higher = faster.
#    If negative, liquid waves will move backwards.
#
#    Requires: enable_waving_water
[client]
(Waving liquids wave speed) 5.0
]]
---@field water_wave_speed number?

-- ----------- [Graphics and Audio] [*Effects] [**Dynamic shadows] ---------- --

--[[
WIPDOC
]]
---@class _.LuantiSettings.graphics_and_audio.effects.dynamic_shadows
--[[
#    Set to true to enable Shadow Mapping.
#
#    Requires: opengl
[client]
(Dynamic shadows) false
]]
---@field enable_dynamic_shadows boolean?
--[[
#    Set the shadow strength gamma.
#    Adjusts the intensity of in-game dynamic shadows.
#    Lower value means lighter shadows, higher value means darker shadows.
#
#    Requires: enable_dynamic_shadows, opengl
[client]
(Shadow strength gamma) 1.0 0.1 10.0
]]
---@field shadow_strength_gamma number?
--[[
#    Maximum distance to render shadows.
#
#    Requires: enable_dynamic_shadows, opengl
[client]
(Shadow map max distance in nodes to render shadows) 140.0 10.0 1000.0
]]
---@field shadow_map_max_distance number?
--[[
#    Texture size to render the shadow map on.
#    This must be a power of two.
#    Bigger numbers create better shadows but it is also more expensive.
#
#    Requires: enable_dynamic_shadows, opengl
[client]
(Shadow map texture size) 2048 128 8192
]]
---@field shadow_map_texture_size integer?
--[[
#    Sets shadow texture quality to 32 bits.
#    On false, 16 bits texture will be used.
#    This can cause much more artifacts in the shadow.
#
#    Requires: enable_dynamic_shadows, opengl
[client]
(Shadow map texture in 32 bits) true
]]
---@field shadow_map_texture_32bit boolean?

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.shadow_filters
--- | "0"
--- | "1"
--- | "2"

---@class _.LuantiSettings.graphics_and_audio.effects.dynamic_shadows
--[[
#    Define shadow filtering quality.
#    This simulates the soft shadows effect by applying a PCF or Poisson disk
#    but also uses more resources.
#
#    Requires: enable_dynamic_shadows, opengl
[client]
(Shadow filter quality) 1 0,1,2
]]
---@field shadow_filters core.LuantiSettings.enums.shadow_filters?
--[[
#    Enable colored shadows for transculent nodes.
#    This is expensive.
#
#    Requires: enable_dynamic_shadows, opengl
[client]
(Colored shadows) false
]]
---@field shadow_map_color boolean?
--[[
#    Set the soft shadow radius size.
#    Lower values mean sharper shadows, bigger values mean softer shadows.
#    Minimum value: 1.0; maximum value: 15.0
#
#    Requires: enable_dynamic_shadows, opengl
[client]
(Soft shadow radius) 5.0 1.0 15.0
]]
---@field shadow_soft_radius number?
--[[
#    Set the default tilt of Sun/Moon orbit in degrees.
#    Games may change orbit tilt via API.
#    Value of 0 means no tilt / vertical orbit.
#
#    Requires: enable_dynamic_shadows, opengl
[client]
(Sky Body Orbit Tilt) 0.0 -60.0 60.0
]]
---@field shadow_sky_body_orbit_tilt number?

-- ----------- [Graphics and Audio] [*Effects] [**Post Processing] ---------- --

--[[
WIPDOC
]]
---@class _.LuantiSettings.graphics_and_audio.effects.post_processing
--[[
#    Enables the post processing pipeline.
[client]
(Enable Post Processing) true
]]
---@field enable_post_processing boolean?
--[[
#    Enables Hable's 'Uncharted 2' filmic tone mapping.
#    Simulates the tone curve of photographic film and how this approximates the
#    appearance of high dynamic range images. Mid-range contrast is slightly
#    enhanced, highlights and shadows are gradually compressed.
#
#    Requires: enable_post_processing
[client]
(Filmic tone mapping) false
]]
---@field tone_mapping boolean?
--[[
#    Enable automatic exposure correction
#    When enabled, the post-processing engine will
#    automatically adjust to the brightness of the scene,
#    simulating the behavior of human eye.
#
#    Requires: enable_post_processing
[client]
(Enable Automatic Exposure) false
]]
---@field enable_auto_exposure boolean?
--[[
#    Set the exposure compensation in EV units.
#    Value of 0.0 (default) means no exposure compensation.
#    Range: from -1 to 1.0
#
#    Requires: enable_post_processing, enable_auto_exposure
[client]
(Exposure compensation) 0.0 -1.0 1.0
]]
---@field exposure_compensation number?
--[[
#    Apply dithering to reduce color banding artifacts.
#    Dithering significantly increases the size of losslessly-compressed
#    screenshots and it works incorrectly if the display or operating system
#    performs additional dithering or if the color channels are not quantized
#    to 8 bits.
#    With OpenGL ES, dithering only works if the shader supports high
#    floating-point precision and it may have a higher performance impact.
#
#    Requires: enable_post_processing
[client]
(Enable Debanding) true
]]
---@field debanding boolean?
--[[
#    Set to true to enable bloom effect.
#    Bright colors will bleed over the neighboring objects.
#
#    Requires: enable_post_processing
[client]
(Enable Bloom) false
]]
---@field enable_bloom boolean?
--[[
#    Set to true to enable volumetric lighting effect (a.k.a. "Godrays").
#
#    Requires: enable_post_processing, enable_bloom
[client]
(Volumetric lighting) false
]]
---@field enable_volumetric_lighting boolean?

-- ------------ [Graphics and Audio] [*Effects] [**Other Effects] ----------- --

--[[
WIPDOC
]]
---@class _.LuantiSettings.graphics_and_audio.effects.other_effects
--[[
#   Simulate translucency when looking at foliage in the sunlight.
#
#   Requires: enable_dynamic_shadows
[client]
(Translucent foliage) false
]]
---@field enable_translucent_foliage boolean?
--[[
#   When enabled, liquid reflections are simulated.
#
#   Requires: enable_waving_water, enable_dynamic_shadows
[client]
(Liquid reflections) false
]]
---@field enable_water_reflections boolean?

-- ---------------------- [Graphics and Audio] [*Audio] --------------------- --

--[[
WIPDOC
]]
---@class _.LuantiSettings.graphics_and_audio.audio
--[[
#    Volume of all sounds.
#    Requires the sound system to be enabled.
[client]
(Volume) 0.8 0.0 1.0
]]
---@field sound_volume number?
--[[
#    Volume multiplier when the window is unfocused.
[client]
(Volume when unfocused) 0.3 0.0 1.0
]]
---@field sound_volume_unfocused number?
--[[
#    Whether to mute sounds. You can unmute sounds at any time.
#    In-game, you can toggle the mute state with the mute key or by using the
#    pause menu.
[client]
(Mute sound) false
]]
---@field mute_sound boolean?

-- ----------------- [Graphics and Audio] [*User Interfaces] ---------------- --

--[[
WIPDOC
]]
---@alias core.LuantiSettings.enums.language
--- | "be"
--- | "bg"
--- | "ca"
--- | "cs"
--- | "da"
--- | "de"
--- | "el"
--- | "en"
--- | "eo"
--- | "es"
--- | "et"
--- | "eu"
--- | "fi"
--- | "fr"
--- | "gd"
--- | "gl"
--- | "hu"
--- | "id"
--- | "it"
--- | "ja"
--- | "jbo"
--- | "kk"
--- | "ko"
--- | "lt"
--- | "lv"
--- | "ms"
--- | "nb"
--- | "nl"
--- | "nn"
--- | "pl"
--- | "pt"
--- | "pt_BR"
--- | "ro"
--- | "ru"
--- | "sk"
--- | "sl"
--- | "sr_Cyrl"
--- | "sr_Latn"
--- | "sv"
--- | "sw"
--- | "tr"
--- | "uk"
--- | "vi"
--- | "zh_CN"
--- | "zh_TW"

--[[
WIPDOC
]]
---@class _.LuantiSettings.graphics_and_audio.user_interface
--[[
#    Set the language. By default, the system language is used.
#    A restart is required after changing this.
[client]
(Language) ,be,bg,ca,cs,da,de,el,en,eo,es,et,eu,fi,fr,gd,gl,hu,id,it,ja,jbo,kk,ko,lt,lv,ms,nb,nl,nn,pl,pt,pt_BR,ro,ru,sk,sl,sr_Cyrl,sr_Latn,sv,sw,tr,uk,vi,zh_CN,zh_TW
]]
---@field language core.LuantiSettings.enums.language?

-- ------------- [Graphics and Audio] [*User Interface] [**GUI] ------------- --

--[[
WIPDOC
]]
---@class _.LuantiSettings.graphics_and_audio.user_interface.gui
--[[
#    When enabled, the GUI is optimized to be more usable on touchscreens.
#    Whether this is enabled by default depends on your hardware form-factor.
[client]
(Optimize GUI for touchscreens) false
]]
---@field touch_gui boolean?
--[[
#    Scale GUI by a user specified value.
#    Use a nearest-neighbor-anti-alias filter to scale the GUI.
#    This will smooth over some of the rough edges, and blend
#    pixels when scaling down, at the cost of blurring some
#    edge pixels when images are scaled by non-integer sizes.
[client]
(GUI scaling) 1.0 0.5 20
]]
---@field gui_scaling number?
--[[
#    Enables smooth scrolling.
[client]
(Smooth scrolling) true
]]
---@field smooth_scrolling boolean?
--[[
#    Enables animation of inventory items.
[client]
(Inventory items animations) false
]]
---@field inventory_items_animations boolean?
--[[
#    Formspec full-screen background opacity (between 0 and 255).
[client]
(Formspec Full-Screen Background Opacity) 140 0 255
]]
---@field formspec_fullscreen_bg_opacity integer?
--[[
#    Formspec full-screen background color (R,G,B).
[client]
(Formspec Full-Screen Background Color) (0,0,0)
]]
---@field formspec_fullscreen_bg_color string?
--[[
#    When gui_scaling_filter is true, all GUI images need to be
#    filtered in software, but some images are generated directly
#    to hardware (e.g. render-to-texture for nodes in inventory).
[client]
(GUI scaling filter) false
]]
---@field gui_scaling_filter boolean?
--[[
#    Delay showing tooltips, stated in milliseconds.
[client]
(Tooltip delay) 400 0 18446744073709551615
]]
---@field tooltip_show_delay integer?
--[[
#    Append item name to tooltip.
[client]
(Append item name) false
]]
---@field tooltip_append_itemname boolean?
--[[
#    Use a cloud animation for the main menu background.
[client]
(Clouds in menu) true
]]
---@field menu_clouds boolean?

-- ------------- [Graphics and Audio] [*User Interface] [**HUD] ------------- --

--[[
WIPDOC
]]
---@class _.LuantiSettings.graphics_and_audio.user_interface.hud
--[[
#    Modifies the size of the HUD elements.
[client]
(HUD scaling) 1.0 0.5 20
]]
---@field hud_scaling number?
--[[
#    Whether name tag backgrounds should be shown by default.
#    Mods may still set a background.
[client]
(Show name tag backgrounds by default) true
]]
---@field show_nametag_backgrounds boolean?
--[[
#    Whether to show the client debug info (has the same effect as hitting F5).
[client]
(Show debug info) false
]]
---@field show_debug boolean?
--[[
#    Radius to use when the block bounds HUD feature is set to near blocks.
[client]
(Block bounds HUD radius) 4 0 1000
]]
---@field show_block_bounds_radius_near integer?
--[[
#    Maximum proportion of current window to be used for hotbar.
#    Useful if there's something to be displayed right or left of hotbar.
[client]
(Maximum hotbar width) 1.0 0.001 1.0
]]
---@field hud_hotbar_max_width number?

-- ------------- [Graphics and Audio] [*User Interface] [**Chat] ------------ --

--[[
WIPDOC
]]
---@class _.LuantiSettings.graphics_and_audio.user_interface.chat
--[[
#    Maximum number of recent chat messages to show
[client]
(Recent Chat Messages) 6 2 20
]]
---@field recent_chat_messages integer?
--[[
#    In-game chat console height, between 0.1 (10%) and 1.0 (100%).
[client]
(Console height) 0.6 0.1 1.0
]]
---@field console_height number?
--[[
#    In-game chat console background color (R,G,B).
[client]
(Console color) (0,0,0)
]]
---@field console_color string?
--[[
#    In-game chat console background alpha (opaqueness, between 0 and 255).
[client]
(Console alpha) 200 0 255
]]
---@field console_alpha integer?
--[[
#    Optional override for chat weblink color.
[client]
(Weblink color) #8888FF
]]
---@field chat_weblink_color string?
--[[
#    Font size of the recent chat text and chat prompt in point (pt).
#    Value 0 will use the default font size.
[client]
(Chat font size) 0 0 72
]]
---@field chat_font_size integer?


-- ------ [Graphics and Audio] [*User Interface] [**Content Repository] ----- --

--[[
WIPDOC
]]
---@class _.LuantiSettings.graphics_and_audio.user_interfaces.content_repository
--[[
#    The URL for the content repository
[client]
(ContentDB URL) https://content.luanti.org
]]
---@field contentdb_url string?
--[[
#    If enabled and you have ContentDB packages installed, Luanti may contact ContentDB to
#    check for package updates when opening the mainmenu.
[client]
(Enable updates available indicator on content tab) true
]]
---@field contentdb_enable_updates_indicator boolean?
--[[
#    Comma-separated list of flags to hide in the content repository.
#    "nonfree" can be used to hide packages which do not qualify as 'free software',
#    as defined by the Free Software Foundation.
#    You can also specify content ratings.
#    These flags are independent from Luanti versions,
#    so see a full list at https://content.luanti.org/help/content_flags/
[client]
(ContentDB Flag Blacklist) nonfree, desktop_default
]]
---@field contentdb_flag_blacklist string?
--[[
#    Maximum number of concurrent downloads. Downloads exceeding this limit will be queued.
#    This should be lower than curl_parallel_limit.
[client]
(ContentDB Max Concurrent Downloads) 3 1
]]
---@field contentdb_max_concurrent_downloads integer?