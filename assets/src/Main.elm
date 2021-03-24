module Main exposing (..)

import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Form as Form
import Bootstrap.Form.Checkbox as Checkbox
import Bootstrap.Form.Fieldset as Fieldset
import Bootstrap.Form.Input as Input
import Bootstrap.Form.Radio as Radio
import Bootstrap.Form.Select as Select
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Navbar as Navbar
import Bootstrap.Spinner as Spinner
import Bootstrap.Text as Text
import Bootstrap.Utilities.Spacing as Spacing
import Browser
import Html exposing (..)
import Html.Attributes exposing (attribute, class, for, id, name, src, style, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as D exposing (Decoder)
import Json.Encode as E
import Process
import RemoteData exposing (RemoteData(..), WebData)
import Task



---- MODEL ----


type Model
    = Home LoginActionState Navbar.State
    | SelectJokester (List Jokester) Navbar.State
    | WriteJoke WriteJokeState Navbar.State
    | ThankYouScreen Navbar.State
    | SettingsScreen Navbar.State
    | ViewingJokes ViewingJokesState Navbar.State


type ViewingJokesState
    = ViewAllJokes RemoteJokes
    | ViewPersonJokes String Jokes
    | ViewSingleJoke Joke LoadedJokesToReturnTo


type alias LoadedJokesToReturnTo =
    Jokes


type alias Jokes =
    List Joke


type LoginActionState
    = LoggedOut UsernameTypings PasswordTypings
    | LoginRequestSent UsernameTypings PasswordTypings
    | ErrorLoggingIn String UsernameTypings PasswordTypings
    | RegisterNewUser UsernameTypings PasswordTypings EmailTypings FirstNameTypings FamilyNameTypings


type alias FamilyNameTypings =
    String


type alias FirstNameTypings =
    String


type alias EmailTypings =
    String


type alias UsernameTypings =
    String


type alias PasswordTypings =
    String


type WriteJokeState
    = TypingOutJoke Jokester String
    | SavingJoke Jokester String


type alias RemoteJokesters =
    WebData (List Jokester)


type alias RemoteJokes =
    WebData (List Joke)


type alias Joke =
    { content : String
    , id : String
    , jokester : Jokester
    }


type Jokester
    = Jokester String String


init : ( Model, Cmd Msg )
init =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg
    in
    ( ViewingJokes (ViewAllJokes Loading) navbarState, Cmd.batch [ getAllRemoteJokes, navbarCmd ] )



---- UPDATE ----


type Msg
    = UserClickedLogJoke
    | UserClickedGoToSettings
    | UserClickedJokeCard Joke
    | UserClickedReturnToAllJokes
    | UserSelectedJokester Jokester
    | WriteJokeTypings String
    | UserClickedSubmitJoke
    | UserClickedRegister
    | ReturnToHome
    | UserClickedViewAllJokes
    | UserClickedNavigateHome
    | UserClickedAPerson String
    | UserClickedTheDeleteButton String
    | UserClickedCreateAccount
    | ServerRespondedToJokeSubmission (Result Http.Error String)
    | ServerSentJokes (Result Http.Error (List Joke))
    | ServerSentJokesters (Result Http.Error (List Jokester))
    | DeleteUp (Result Http.Error String)
    | UserTypingEmail String
    | UserTypingUsername String
    | UserTypingPassword String
    | UserClickedLogin
    | ServerRespondedToLogoutAttempt (Result Http.Error ())
    | ServerRespondedToLoginAttempt (Result Http.Error ())
    | ServerRespondedToRegisterAttempt (Result Http.Error ())
    | UserClickedLogOut
    | NavbarMsg Navbar.State
    | NOOP


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NOOP ->
            ( model, Cmd.none )

        NavbarMsg newNavState ->
            ( handleNewNavbarState model newNavState, Cmd.none )

        UserClickedLogOut ->
            ( model, sendLogoutAttempt )

        UserTypingPassword str ->
            case model of
                Home (LoggedOut uT pT) navState ->
                    ( Home (LoggedOut uT str) navState, Cmd.none )

                Home (RegisterNewUser uT pT eT fNT famT) navState ->
                    ( Home (RegisterNewUser uT str eT fNT famT) navState, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        UserTypingEmail str ->
            case model of
                Home (RegisterNewUser uT pT eT fNT famT) navState ->
                    ( Home (RegisterNewUser uT pT str fNT famT) navState, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        UserTypingUsername str ->
            case model of
                Home (LoggedOut uT pT) navState ->
                    ( Home (LoggedOut str pT) navState, Cmd.none )

                Home (RegisterNewUser uT pT eT fNT famT) navState ->
                    ( Home (RegisterNewUser str pT eT fNT famT) navState, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        UserClickedCreateAccount ->
            case model of
                Home ((RegisterNewUser _ _ _ _ _) as registerState) navState ->
                    ( Home registerState navState, sendRegisterAttempt registerState )

                _ ->
                    ( model, Cmd.none )

        UserClickedRegister ->
            case model of
                Home (LoggedOut uT pT) navState ->
                    ( Home (RegisterNewUser uT pT "" "" "") navState, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        UserClickedLogin ->
            case model of
                Home (LoggedOut uT pT) navState ->
                    ( Home (LoginRequestSent uT pT) navState, sendLoginAttempt uT pT )

                _ ->
                    ( model, Cmd.none )

        ServerRespondedToLogoutAttempt resp ->
            ( Home (LoggedOut "" "") (getNavStateFromModel model), Cmd.none )

        ServerRespondedToRegisterAttempt resp ->
            case model of
                Home _ navState ->
                    case resp of
                        Ok _ ->
                            ( ViewingJokes (ViewAllJokes Loading) navState, getAllRemoteJokes )

                        Err e ->
                            ( Home (ErrorLoggingIn "woops" "" "") navState, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ServerRespondedToLoginAttempt resp ->
            case model of
                Home _ navState ->
                    case resp of
                        Ok _ ->
                            ( ViewingJokes (ViewAllJokes Loading) navState, getAllRemoteJokes )

                        Err e ->
                            ( Home (ErrorLoggingIn "woops" "" "") navState, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ReturnToHome ->
            ( model, getAllRemoteJokes )

        UserClickedAPerson name ->
            case model of
                ViewingJokes (ViewAllJokes (Success jokes)) navState ->
                    let
                        personsJokes =
                            List.filter (\j -> name == jokesterToName j.jokester) jokes
                    in
                    ( ViewingJokes (ViewPersonJokes name personsJokes) navState, Cmd.none )

                _ ->
                    --ignore if we're not on the view all jokes screen
                    ( model, Cmd.none )

        UserClickedReturnToAllJokes ->
            case model of
                ViewingJokes (ViewSingleJoke _ loadedJokes) navState ->
                    ( ViewingJokes (ViewAllJokes (Success loadedJokes)) (getNavStateFromModel model), getAllRemoteJokes )

                _ ->
                    ( model, Cmd.none )

        UserClickedJokeCard joke ->
            case model of
                ViewingJokes (ViewAllJokes (Success loadedJokes)) navState ->
                    ( ViewingJokes (ViewSingleJoke joke loadedJokes) navState, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        UserClickedViewAllJokes ->
            ( ViewingJokes (ViewAllJokes Loading) (getNavStateFromModel model), getAllRemoteJokes )

        UserClickedNavigateHome ->
            ( model, getAllRemoteJokes )

        UserClickedLogJoke ->
            ( model, getAllRemoteJokesters )

        UserClickedGoToSettings ->
            ( SettingsScreen (getNavStateFromModel model), Cmd.none )

        UserSelectedJokester jokester ->
            ( WriteJoke (TypingOutJoke jokester "") (getNavStateFromModel model), Cmd.none )

        UserClickedSubmitJoke ->
            userSubmittedJokeUpdate model

        UserClickedTheDeleteButton ident ->
            ( model, deleteTheAPI ident )

        ServerRespondedToJokeSubmission httpResult ->
            case httpResult of
                Ok status ->
                    ( ThankYouScreen (getNavStateFromModel model), scheduleReturnToHome )

                Err e ->
                    ( model, Cmd.none )

        ServerSentJokesters httpResult ->
            case httpResult of
                Ok jokesters ->
                    ( SelectJokester jokesters (getNavStateFromModel model), Cmd.none )

                Err e ->
                    ( model, Cmd.none )

        ServerSentJokes httpResult ->
            case httpResult of
                Ok jokes ->
                    ( ViewingJokes (ViewAllJokes (Success jokes)) (getNavStateFromModel model), Cmd.none )

                Err e ->
                    ( Home (LoggedOut "" "") (getNavStateFromModel model), Cmd.none )

        DeleteUp test ->
            case ( model, test ) of
                ( ViewingJokes (ViewAllJokes rj) navState, Ok deletedId ) ->
                    case rj of
                        Success jokes ->
                            let
                                updatedJokes =
                                    List.filter (\x -> x.id /= deletedId) jokes
                            in
                            ( ViewingJokes (ViewAllJokes (Success updatedJokes)) navState, Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                ( ViewingJokes (ViewSingleJoke _ loadedJokesToReturnTo) navState, Ok deletedId ) ->
                    let
                        updatedLoadedJokes =
                            List.filter (\x -> x.id /= deletedId) loadedJokesToReturnTo
                    in
                    ( ViewingJokes (ViewAllJokes (Success updatedLoadedJokes)) navState, getAllRemoteJokes )

                _ ->
                    ( model, Cmd.none )

        WriteJokeTypings s ->
            ( writeJokeUpdate s model, Cmd.none )


handleNewNavbarState model newNavState =
    case model of
        Home loginState _ ->
            Home loginState newNavState

        SelectJokester sJState _ ->
            SelectJokester sJState newNavState

        WriteJoke wJState _ ->
            WriteJoke wJState newNavState

        ThankYouScreen _ ->
            ThankYouScreen newNavState

        SettingsScreen _ ->
            SettingsScreen newNavState

        ViewingJokes vJState _ ->
            ViewingJokes vJState newNavState


getNavStateFromModel model =
    case model of
        Home _ navState ->
            navState

        SelectJokester sJState navState ->
            navState

        WriteJoke wJState navState ->
            navState

        ThankYouScreen navState ->
            navState

        SettingsScreen navState ->
            navState

        ViewingJokes vJState navState ->
            navState


sendLogoutAttempt =
    Http.get
        { url = "/logout"
        , expect = Http.expectWhatever ServerRespondedToLogoutAttempt
        }


sendRegisterAttempt registerState =
    case registerState of
        RegisterNewUser username password email firstName familyName ->
            Http.post
                { url = "/register"
                , expect = Http.expectWhatever ServerRespondedToRegisterAttempt
                , body =
                    Http.jsonBody <|
                        E.object
                            [ ( "email", E.string email )
                            , ( "username", E.string username )
                            , ( "password", E.string password )
                            , ( "family_name", E.string familyName )
                            , ( "first_name", E.string firstName )
                            ]
                }

        _ ->
            Cmd.none


sendLoginAttempt username passwd =
    Http.post
        { url = "/login"
        , expect = Http.expectWhatever ServerRespondedToLoginAttempt
        , body =
            Http.jsonBody <|
                E.object
                    [ ( "username", E.string username )
                    , ( "password", E.string passwd )
                    ]
        }


userSubmittedJokeUpdate : Model -> ( Model, Cmd Msg )
userSubmittedJokeUpdate model =
    case model of
        WriteJoke (TypingOutJoke jokester "") navState ->
            ( model, getAllRemoteJokes )

        WriteJoke (TypingOutJoke jokester typings) navState ->
            ( WriteJoke (SavingJoke jokester typings) navState, mkJoke typings "" jokester |> postNewJoke )

        _ ->
            ( model, Cmd.none )


writeJokeUpdate : String -> Model -> Model
writeJokeUpdate newTypings model =
    case model of
        WriteJoke (TypingOutJoke jokester oldTypings) navState ->
            WriteJoke (TypingOutJoke jokester newTypings) navState

        _ ->
            model


scheduleReturnToHome : Cmd Msg
scheduleReturnToHome =
    Task.perform (always ReturnToHome) <| Process.sleep 1000


getAllRemoteJokesters : Cmd Msg
getAllRemoteJokesters =
    Http.get
        { url = "/api/persons"
        , expect = Http.expectJson ServerSentJokesters (D.field "data" jokestersDecoder)
        }


getAllRemoteJokes : Cmd Msg
getAllRemoteJokes =
    Http.get
        { url = "/api/jokes"
        , expect = Http.expectJson ServerSentJokes (D.field "data" jokesDecoder)
        }


postNewJoke : Joke -> Cmd Msg
postNewJoke joke =
    Http.post
        { url = "/api/jokes"
        , expect = Http.expectString ServerRespondedToJokeSubmission
        , body = Http.jsonBody <| jokeEncoder joke
        }


deleteTheAPI : String -> Cmd Msg
deleteTheAPI ident =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = "/api/jokes/" ++ ident
        , body = Http.emptyBody
        , expect = Http.expectJson DeleteUp D.string
        , timeout = Nothing
        , tracker = Nothing
        }


jokestersDecoder : Decoder (List Jokester)
jokestersDecoder =
    D.list jokesterDecoder


jokesDecoder : Decoder (List Joke)
jokesDecoder =
    D.list jokeDecoder


mkJoke : String -> String -> Jokester -> Joke
mkJoke content ident jokester =
    Joke content ident jokester


jokeEncoder : Joke -> E.Value
jokeEncoder joke =
    case joke.jokester of
        Jokester _ jokeseterId ->
            E.object
                [ ( "joke"
                  , E.object
                        [ ( "content", E.string joke.content )
                        , ( "person_id", E.string jokeseterId )
                        ]
                  )
                ]


jokeDecoder : Decoder Joke
jokeDecoder =
    D.map3 mkJoke
        (D.field "content" D.string)
        (D.field "id" D.string)
        (D.field "person" jokesterDecoder)


jokesterDecoder : Decoder Jokester
jokesterDecoder =
    D.map2 Jokester
        (D.field "name" D.string)
        (D.field "id" D.string)



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        renderNavBar =
            case model of
                Home _ _ ->
                    text ""

                _ ->
                    navBarView model

        body =
            case model of
                Home homeM navState ->
                    loginInHomeView homeM

                ViewingJokes state navState ->
                    case state of
                        ViewAllJokes remoteJokes ->
                            viewAllJokesView remoteJokes

                        ViewSingleJoke joke _ ->
                            singleFullJokeView joke

                        ViewPersonJokes name jokes ->
                            jokesView ("Jokes of " ++ name) jokes

                SelectJokester jokesters navState ->
                    selectJokestersView jokesters

                WriteJoke writeJokeState navState ->
                    writeJokeViewWrapper writeJokeState

                ThankYouScreen navState ->
                    div [ class "" ] [ h1 [] [ text "thanks for sharing \u{1F917}" ] ]

                SettingsScreen _ ->
                    settingsView
    in
    div []
        [ renderNavBar
        , body
        ]


settingsView =
    div [ class "" ] [ h1 [] [ text "settings page" ] ]


navBarView model =
    Navbar.config NavbarMsg
        |> Navbar.withAnimation
        |> Navbar.brand [ styleCursorPointer, onClick UserClickedNavigateHome ]
            [ text "Funny App" ]
        |> Navbar.items
            (List.map navItemView
                [ ( UserClickedLogJoke, "Write down new joke" )
                , ( UserClickedGoToSettings, "Settings" )
                , ( UserClickedLogOut, "Logout" )
                ]
            )
        |> Navbar.view (getNavStateFromModel model)


navItemView ( msg, ctaText ) =
    Navbar.itemLink [ styleCursorPointer, onClick msg ]
        [ text ctaText ]


styleCursorPointer =
    style "cursor" "pointer"


writeJokeViewWrapper : WriteJokeState -> Html Msg
writeJokeViewWrapper writeJokeState =
    case writeJokeState of
        TypingOutJoke jokester s ->
            writeJokeView jokester s

        SavingJoke jokester s ->
            writeJokeView jokester s


loginInHomeView : LoginActionState -> Html Msg
loginInHomeView hM =
    Grid.container []
        [ Grid.row [ Row.centerXs ]
            [ Grid.col
                [ Col.xsAuto ]
                [ Grid.row [ rowSpacing Spacing.mt4, rowSpacing Spacing.mb5 ] [ titleColumn ]
                , Grid.row [] [ loginStatusColumn hM ]
                ]
            ]
        ]


titleColumn : Grid.Column Msg
titleColumn =
    Grid.col [ Col.attrs [ styleCursorPointer, onClick ReturnToHome ] ]
        [ Grid.row [ Row.centerXs ] [ Grid.col [ Col.xsAuto ] [ h1 [] [ text "Someone Had A" ] ] ]
        , Grid.row [ Row.centerXs ] [ Grid.col [ Col.xsAuto ] [ h1 [] [ text "Very" ] ] ]
        , Grid.row [ Row.centerXs ] [ Grid.col [ Col.xsAuto ] [ h1 [] [ text "Funny Joke Today" ] ] ]
        ]


loginPromptForReturningUser uT pT =
    [ Form.form []
        [ Form.group []
            [ Form.label [ for "username" ] [ text "Username" ]
            , Input.text
                [ Input.id "username"
                , Input.value uT
                , Input.onInput UserTypingUsername
                ]
            ]
        , Form.group []
            [ Form.label [ for "mypwd" ] [ text "Password" ]
            , Input.password
                [ Input.id "mypwd"
                , Input.value pT
                , Input.onInput UserTypingPassword
                ]
            ]
        , Button.button
            [ Button.primary
            , Button.onClick UserClickedLogin
            ]
            [ text "Sign in" ]
        ]
    , Button.button
        [ Button.secondary
        , Button.onClick UserClickedRegister
        ]
        [ text "New here? Register" ]
    ]


registerFormForNewUser uT pT eT fNT famT =
    [ Form.form []
        [ Form.group []
            [ Form.label [ for "email" ] [ text "Email (optional)" ]
            , Input.text
                [ Input.id "email"
                , Input.value eT
                , Input.onInput UserTypingEmail
                ]
            ]
        , Form.group []
            [ Form.label [ for "username" ] [ text "Username" ]
            , Input.text
                [ Input.id "username"
                , Input.value uT
                , Input.onInput UserTypingUsername
                ]
            ]
        , Form.group []
            [ Form.label [ for "mypwd" ] [ text "Password" ]
            , Input.password
                [ Input.id "mypwd"
                , Input.value pT
                , Input.onInput UserTypingPassword
                ]
            ]
        , Button.button
            [ Button.primary
            , Button.onClick UserClickedCreateAccount
            ]
            [ text "Create Account" ]
        ]
    ]


loginStatusColumn hM =
    case hM of
        LoggedOut uT pT ->
            Grid.col [] <| loginPromptForReturningUser uT pT

        LoginRequestSent _ _ ->
            Grid.col [] [ text "LoginRequestSent" ]

        RegisterNewUser uT pT eT fNT famT ->
            Grid.col [] <| registerFormForNewUser uT pT eT fNT famT

        ErrorLoggingIn _ _ _ ->
            Grid.col []
                [ text "error"
                ]


viewAllJokesView : RemoteJokes -> Html Msg
viewAllJokesView remoteJokes =
    case remoteJokes of
        Loading ->
            let
                customStyles =
                    [ style "width" "5rem", style "height" "5rem" ]
            in
            Grid.container []
                [ Grid.row [ Row.centerXs, rowSpacing Spacing.mt5 ]
                    [ Grid.col [ Col.xsAuto ] [ Spinner.spinner [ Spinner.attrs customStyles ] [] ]
                    ]
                ]

        Success jokes ->
            jokesView "Jokes of the whole family" jokes

        _ ->
            text "ERROR OROROERJFKSDOJKLDSFJ LKDSFJ"


jokesView : String -> List Joke -> Html Msg
jokesView title jokes =
    let
        theJokes =
            case jokes of
                [] ->
                    [ h5 [] [ text "No jokes just yet" ] ]

                _ ->
                    List.map jokeView jokes
    in
    Grid.container []
        [ Grid.row
            [ Row.centerXs, rowSpacing Spacing.mt3 ]
            [ Grid.col [ Col.xsAuto ] [ h3 [] [ text title ] ] ]
        , Grid.row [ Row.centerXs, rowSpacing Spacing.mb5 ]
            [ Grid.col [ Col.xsAuto ] theJokes ]
        ]


singleFullJokeView : Joke -> Html Msg
singleFullJokeView joke =
    Grid.container []
        [ Grid.row
            [ Row.leftXs, rowSpacing Spacing.mt3 ]
            [ Grid.col [ Col.xsAuto ]
                [ h5 [ styleCursorPointer, onClick UserClickedReturnToAllJokes ]
                    [ text "<-- Back" ]
                ]
            ]
        , Grid.row [ Row.centerXs, rowSpacing Spacing.mb5 ]
            [ Grid.col [ Col.xsAuto ]
                [ Card.config [ Card.attrs [ onClick <| UserClickedJokeCard joke, style "width" "20rem", Spacing.mt3 ] ]
                    |> Card.block [] [ Block.text [] [ text joke.content ] ]
                    |> Card.block [ Block.align Text.alignXsRight ]
                        [ Block.titleH4 [] [ text (jokesterToName joke.jokester) ] ]
                    |> Card.block [ Block.align Text.alignXsLeft ]
                        [ Block.custom <|
                            Button.button
                                [ Button.outlineDanger
                                , Button.onClick (UserClickedTheDeleteButton joke.id)
                                ]
                                [ text "Delete" ]
                        ]
                    |> Card.view
                ]
            ]
        ]


type ShouldShowDeleteOption
    = ShowDelete
    | HideDelete


rowSpacing space =
    Row.attrs [ space ]


jokeView : Joke -> Html Msg
jokeView joke =
    Card.config [ Card.attrs [ styleCursorPointer, onClick <| UserClickedJokeCard joke, style "width" "20rem", Spacing.mt3 ] ]
        |> Card.block []
            [ Block.text [] [ text joke.content ]
            ]
        |> Card.block [ Block.align Text.alignXsRight ]
            [ Block.titleH4 [] [ text (jokesterToName joke.jokester) ] ]
        |> Card.view


jokesterToName (Jokester name _) =
    name


flip f y x =
    f x y


selectJokestersView : List Jokester -> Html Msg
selectJokestersView jokesters =
    div [ class "" ]
        [ h1 [] [ text "Who was HILARIOUS?" ]
        , ListGroup.ul
            (List.map
                selectJokesterView
                jokesters
            )
        ]


selectJokesterView ((Jokester name _) as jokester) =
    ListGroup.li
        [ ListGroup.attrs
            [ onClick <| UserSelectedJokester jokester
            ]
        ]
        [ span [ class "name" ] [ text name ], span [ class "right-caret" ] [ text ">" ] ]


writeJokeView : Jokester -> String -> Html Msg
writeJokeView j s =
    div [ class "write-joke-view" ]
        [ h1 [] [ plopInName j ]
        , Textarea.textarea [ Textarea.rows 14, Textarea.attrs [ onInput WriteJokeTypings, class "textarea", value s ] ]
        , Button.button [ Button.primary, Button.onClick UserClickedSubmitJoke ] [ text "submit" ]
        ]


plopInName : Jokester -> Html Msg
plopInName (Jokester name _) =
    span []
        [ text <| "what did " ++ name ++ " say"
        , br [] []
        , text "that made you lol?"
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = \m -> Navbar.subscriptions (getNavStateFromModel m) NavbarMsg
        }
