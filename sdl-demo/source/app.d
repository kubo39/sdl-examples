import bindbc.sdl;
import core.thread;
import std.exception;
import std.format;
import std.string;

shared static this()
{
    assert(SDL_Init(0) == 0);
    assert(SDL_InitSubSystem(SDL_INIT_VIDEO) == 0);
    assert(SDL_InitSubSystem(SDL_INIT_EVENTS) == 0);
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
            const hasPending = SDL_PollEvent(&event) == 1;
            if (!hasPending)
                break;
            if (event.type == SDL_EventType.SDL_QUIT ||
                (event.type == SDL_EventType.SDL_KEYDOWN &&
                 event.key.keysym.sym == SDL_Keycode.SDLK_ESCAPE))
            {
                break L_running;
            }
        }
        enforce(SDL_RenderClear(renderer) == 0,
                format("Could not clear %s", SDL_GetError().fromStringz));
        SDL_RenderPresent(renderer);

        Thread.sleep(1.msecs);
    }
}
