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
    IMG_Init(IMG_INIT_JPG | IMG_INIT_PNG);
}

shared static ~this()
{
    IMG_Quit();
    SDL_QuitSubSystem(SDL_INIT_EVENTS);
    SDL_QuitSubSystem(SDL_INIT_VIDEO);
    SDL_Quit();
}

///
void run(string png)
{
    auto window = SDL_CreateWindow("bindbc-sdl demo: Curosr",
                                   SDL_WINDOWPOS_CENTERED_MASK,
                                   SDL_WINDOWPOS_CENTERED_MASK,
                                   800, 600, SDL_WINDOW_OPENGL);
    assert(window !is null);

    auto renderer = SDL_CreateRenderer(window, -1,
                                       SDL_RendererFlags.SDL_RENDERER_SOFTWARE);
    assert(renderer !is null);

    auto surface = IMG_Load(png.toStringz);
    enforce(surface !is null, format("failed to load cursor image: %s",
                                     SDL_GetError().fromStringz));
    auto cursor = SDL_CreateColorCursor(surface, 0, 0);
    enforce(cursor !is null, format("failed to load cursor: %s"
                                    , SDL_GetError().fromStringz));
    SDL_SetCursor(cursor);

    enforce(SDL_RenderClear(renderer) == 0,
            format("Could not clear %s", SDL_GetError().fromStringz));
    SDL_RenderPresent(renderer);

    enforce(SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255) == 0,
            format("%s", SDL_GetError().fromStringz));

L_mainloop:
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
                break L_mainloop;
            }
            else if (event.type == SDL_EventType.SDL_MOUSEBUTTONDOWN)
            {
                const rect = SDL_Rect(event.button.x, event.button.y, 1, 1);
                SDL_RenderFillRect(renderer, &rect);
                SDL_RenderPresent(renderer);
            }
        }
    }
}

void main(string[] args)
{
    if (args.length < 2)
        writeln("Usage: dub run /path/to/image.(png|jpg)");
    else
        run(args[1]);
}
