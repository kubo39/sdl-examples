import bindbc.sdl;
import core.thread;
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
    auto window = SDL_CreateWindow("bindbc-sdl demo: Events",
                                   SDL_WINDOWPOS_CENTERED_MASK,
                                   SDL_WINDOWPOS_CENTERED_MASK,
                                   800, 600,
                                   SDL_WindowFlags.SDL_WINDOW_RESIZABLE);
    assert(window !is null);
    writeln("here");

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
                break L_running;
            }
            else if (event.type == SDL_EventType.SDL_MOUSEMOTION)
            {
                // skip mouse motion intentionally, because of the verbose it
                // might cause.
                continue;
            }
            else
            {
                writeln(event.type);
            }
        }

        enforce(SDL_RenderClear(renderer) == 0,
                format("Could not clear %s", SDL_GetError().fromStringz));
        SDL_RenderPresent(renderer);
        Thread.sleep(1.msecs);
    }
}
