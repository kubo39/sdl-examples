import bindbc.sdl;
import std.exception;
import std.format;
import std.stdio;
import std.string;

shared static this()
{
    int ret = SDL_Init(0);
    assert(ret == 0);
    ret = SDL_InitSubSystem(SDL_INIT_VIDEO);
    assert(ret == 0);
    ret = SDL_InitSubSystem(SDL_INIT_EVENTS);
    assert(ret == 0);
}

shared static ~this()
{
    SDL_QuitSubSystem(SDL_INIT_EVENTS);
    SDL_QuitSubSystem(SDL_INIT_VIDEO);
    SDL_Quit();
}

void main()
{
    auto window = SDL_CreateWindow("bindbc-sdl demo: Video",
                                   SDL_WINDOWPOS_CENTERED_MASK,
                                   SDL_WINDOWPOS_CENTERED_MASK,
                                   800, 600, SDL_WINDOW_OPENGL);
    assert(window !is null);

    auto renderer = SDL_CreateRenderer(window, -1, SDL_RendererFlags.SDL_RENDERER_ACCELERATED);
    assert(renderer !is null);

    enforce(SDL_SetRenderDrawColor(renderer, 255, 0, 0, 0xFF) == 0,
            format("%s", SDL_GetError().fromStringz));

    enforce(SDL_RenderClear(renderer) == 0,
            format("Could not clear %s", SDL_GetError().fromStringz));
    SDL_RenderPresent(renderer);

L_running:
    while (true)
    {
        while (true)
        {
            SDL_Event event = void;
            if (SDL_PollEvent(&event) != 1)
                break;
            if (event.type == SDL_EventType.SDL_QUIT ||
                (event.type == SDL_EventType.SDL_KEYDOWN &&
                 event.key.keysym.sym == SDL_Keycode.SDLK_ESCAPE))
            {
                SDL_ShowSimpleMessageBox(
                    SDL_MessageBoxFlags.SDL_MESSAGEBOX_ERROR,
                    "Some title",
                    "Some information inside the window",
                    window);
                break L_running;
            }
        }
    }

    SDL_MessageBoxButtonData[] buttons = [
        SDL_MessageBoxButtonData(
            SDL_MessageBoxButtonFlags.SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT,
            1, "Ok"),
        SDL_MessageBoxButtonData(0, 2, "No"),
        SDL_MessageBoxButtonData(
            SDL_MessageBoxButtonFlags.SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT,
            3, "Cancel"),
        ];
    const msgBoxData = SDL_MessageBoxData(
        SDL_MessageBoxFlags.SDL_MESSAGEBOX_WARNING,
        null,
        "Some warning",
        "You forget to do something, do it anyway?",
        cast(int) buttons.length,
        buttons.ptr,
        null);
    int buttonId;
    const result = SDL_ShowMessageBox(&msgBoxData, &buttonId);
    enforce(result == 0, format("SDL error: %s", SDL_GetError().fromStringz));

    if (buttonId == -1)
    {
        writeln("CloseButton");
    }
    else
    {
        import std.algorithm : find;
        const button = buttons.find!(b => b.buttonid == buttonId)[0];
        writefln("CustomButton(%s)", button.text.fromStringz);
    }
}
