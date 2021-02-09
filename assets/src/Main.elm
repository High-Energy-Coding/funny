module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (attribute, class, for, id, name, src, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as D exposing (Decoder)
import Json.Encode as E
import Process
import RemoteData exposing (RemoteData(..), WebData)
import Task



---- MODEL ----


type Model
    = Home HomeModel
    | SelectJokester (List Jokester)
    | WriteJoke WriteJokeState
    | ThankYouScreen
    | ViewAllJokes RemoteJokes
    | SuccessDELETE


type HomeModel
    = LoggedOut UsernameTypings PasswordTypings
    | LoginRequestSent UsernameTypings PasswordTypings
    | LoggedIn
    | ErrorLoggingIn String UsernameTypings PasswordTypings


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
    ( Home (LoggedOut "" ""), Cmd.none )



---- UPDATE ----


type Msg
    = UserClickedLogJoke
    | UserSelectedJokester Jokester
    | WriteJokeTypings String
    | UserClickedSubmitJoke
    | ReturnToHome
    | UserClickedViewAllJokes
    | UserClickedNavigateHome
    | UserClickedTheDeleteButton String
    | ServerRespondedToJokeSubmission (Result Http.Error String)
    | ServerSentJokes (Result Http.Error (List Joke))
    | ServerSentJokesters (Result Http.Error (List Jokester))
    | DeleteUp (Result Http.Error ())
    | UserTypingUsername String
    | UserTypingPassword String
    | UserClickedLogin
    | ServerRespondedToLogoutAttempt (Result Http.Error ())
    | ServerRespondedToLoginAttempt (Result Http.Error ())
    | UserClickedLogOut
    | NOOP


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NOOP ->
            ( model, Cmd.none )

        UserClickedLogOut ->
            ( model, sendLogoutAttempt )

        UserTypingPassword str ->
            case model of
                Home (LoggedOut uT pT) ->
                    ( Home (LoggedOut uT str), Cmd.none )

                _ ->
                    ( model, Cmd.none )

        UserTypingUsername str ->
            case model of
                Home (LoggedOut uT pT) ->
                    ( Home (LoggedOut str pT), Cmd.none )

                _ ->
                    ( model, Cmd.none )

        UserClickedLogin ->
            case model of
                Home (LoggedOut uT pT) ->
                    ( Home (LoginRequestSent uT pT), sendLoginAttempt uT pT )

                _ ->
                    ( model, Cmd.none )

        ServerRespondedToLogoutAttempt resp ->
            case resp of
                Ok _ ->
                    ( Home (LoggedOut "" ""), Cmd.none )

                Err e ->
                    ( Home (ErrorLoggingIn "woops" "" ""), Cmd.none )

        ServerRespondedToLoginAttempt resp ->
            case resp of
                Ok _ ->
                    ( Home LoggedIn, Cmd.none )

                Err e ->
                    ( Home (ErrorLoggingIn "woops" "" ""), Cmd.none )

        ReturnToHome ->
            ( Home LoggedIn, Cmd.none )

        UserClickedViewAllJokes ->
            ( ViewAllJokes Loading, getAllRemoteJokes )

        UserClickedNavigateHome ->
            ( Home LoggedIn, Cmd.none )

        UserClickedLogJoke ->
            ( Home LoggedIn, getAllRemoteJokesters )

        UserSelectedJokester jokester ->
            ( WriteJoke (TypingOutJoke jokester ""), Cmd.none )

        UserClickedSubmitJoke ->
            userSubmittedJokeUpdate model

        UserClickedTheDeleteButton ident ->
            ( Home (LoggedOut "" ""), deleteTheAPI ident )

        ServerRespondedToJokeSubmission httpResult ->
            case httpResult of
                Ok status ->
                    ( ThankYouScreen, scheduleReturnToHome )

                Err e ->
                    ( model, Cmd.none )

        ServerSentJokesters httpResult ->
            case httpResult of
                Ok jokesters ->
                    ( SelectJokester jokesters, Cmd.none )

                Err e ->
                    ( model, Cmd.none )

        ServerSentJokes httpResult ->
            case httpResult of
                Ok jokes ->
                    ( ViewAllJokes (Success jokes), Cmd.none )

                Err e ->
                    ( ViewAllJokes <| Failure e, Cmd.none )

        DeleteUp test ->
            case test of
                Ok () ->
                    ( ViewAllJokes Loading, getAllRemoteJokes )

                Err e ->
                    ( ViewAllJokes <| Failure e, Cmd.none )

        WriteJokeTypings s ->
            ( writeJokeUpdate s model, Cmd.none )


sendLogoutAttempt =
    Http.get
        { url = "/logout"
        , expect = Http.expectWhatever ServerRespondedToLogoutAttempt
        }


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
        WriteJoke (TypingOutJoke jokester "") ->
            ( Home (LoggedOut "" ""), Cmd.none )

        WriteJoke (TypingOutJoke jokester typings) ->
            ( WriteJoke (SavingJoke jokester typings), mkJoke typings "" jokester |> postNewJoke )

        _ ->
            ( model, Cmd.none )


writeJokeUpdate : String -> Model -> Model
writeJokeUpdate newTypings model =
    case model of
        WriteJoke (TypingOutJoke jokester oldTypings) ->
            WriteJoke (TypingOutJoke jokester newTypings)

        _ ->
            model


scheduleReturnToHome : Cmd Msg
scheduleReturnToHome =
    Task.perform (always ReturnToHome) <| Process.sleep 2400


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
        , expect = Http.expectWhatever DeleteUp
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
    div [ class "body" ] <|
        List.singleton <|
            case model of
                Home homeM ->
                    loginInHomeView homeM

                ViewAllJokes remoteJokes ->
                    viewAllJokesView remoteJokes

                SelectJokester jokesters ->
                    selectJokestersView jokesters

                SuccessDELETE ->
                    homeView

                WriteJoke writeJokeState ->
                    writeJokeViewWrapper writeJokeState

                --writeJokeView jokester s
                ThankYouScreen ->
                    div [ class "full-width" ] [ h1 [] [ text "thanks for sharing \u{1F917}" ] ]


writeJokeViewWrapper : WriteJokeState -> Html Msg
writeJokeViewWrapper writeJokeState =
    case writeJokeState of
        TypingOutJoke jokester s ->
            writeJokeView jokester s

        SavingJoke jokester s ->
            writeJokeView jokester s


loginInHomeView : HomeModel -> Html Msg
loginInHomeView hM =
    div [ class "full-width home-view" ]
        [ h1 [ class "h1" ]
            [ text "Someone Had A"
            , br [] []
            , span [ class "very" ] [ text "Very" ]
            , br [] []
            , text "Funny Joke Today"
            ]
        , loginStatus hM
        ]


loginStatus hM =
    case hM of
        LoggedOut uT pT ->
            div []
                [ div []
                    [ label [ for "username" ] [ text "Username:" ]
                    , input
                        [ id "username"
                        , name "username"
                        , type_ "text"
                        , value uT
                        , onInput UserTypingUsername
                        ]
                        []
                    ]
                , div []
                    [ label [ for "pass" ] [ text "Password:" ]
                    , input
                        [ id "pass"
                        , attribute "minlength" "4"
                        , name "password"
                        , attribute "required" ""
                        , type_ "password"
                        , value pT
                        , onInput UserTypingPassword
                        ]
                        []
                    ]
                , button [ onClick UserClickedLogin ] [ text "Sign in" ]
                ]

        LoginRequestSent _ _ ->
            text "LoginRequestSent"

        LoggedIn ->
            div []
                [ button [ onClick UserClickedLogOut ] [ text "log out" ]
                , button [ class "previous-jokes-button", onClick UserClickedViewAllJokes ] [ text "< previous jokes" ]
                , button [ class "write-it-down-button", onClick UserClickedLogJoke ] [ text "write it down >" ]
                ]

        ErrorLoggingIn _ _ _ ->
            text "error"


homeView : Html Msg
homeView =
    div [ class "full-width home-view" ]
        [ h1 [ class "h1" ]
            [ text "Someone Had A"
            , br [] []
            , span [ class "very" ] [ text "Very" ]
            , br [] []
            , text "Funny Joke Today"
            ]
        , button [ class "previous-jokes-button", onClick UserClickedViewAllJokes ] [ text "< previous jokes" ]
        , button [ class "write-it-down-button", onClick UserClickedLogJoke ] [ text "write it down >" ]
        ]


viewAllJokesView : RemoteJokes -> Html Msg
viewAllJokesView remoteJokes =
    case remoteJokes of
        NotAsked ->
            text "WAITING FOR RESPONSE..."

        Loading ->
            text "WAITING FOR RESPONSE..."

        Success jokes ->
            jokesView jokes

        Failure e ->
            text "ERROR OROROERJFKSDOJKLDSFJ LKDSFJ"


jokesView : List Joke -> Html Msg
jokesView jokes =
    div [ class "full-width" ]
        [ h1 [ class "previous-jokes" ] [ text "Previous Jokes." ]
        , div [ class "jokes-view" ] <| List.map jokeView jokes
        , button [ class "back-home", onClick UserClickedNavigateHome ] [ text "home" ]
        ]


jokeView : Joke -> Html Msg
jokeView joke =
    div [ class "joke-view" ]
        [ span [ class "joke-content" ] [ text joke.content ]
        , span [ class "joke-jokester" ] [ text <| jokesterToName joke.jokester ]
        , button [ onClick (UserClickedTheDeleteButton joke.id) ] [ text "Delete" ]
        ]



-- 79cf607f-bf23-48a9-8564-370e4982553c
--(UserClickedTheDeleteButton (String.fromInt person.id))


jokesterToName (Jokester name _) =
    name


flip f y x =
    f x y


selectJokestersView : List Jokester -> Html Msg
selectJokestersView jokesters =
    div [ class "full-width" ]
        [ h1 [] [ text "Who was HILARIOUS?" ]
        , div [ class "jokesters-select" ] <|
            List.map
                selectJokesterView
                jokesters
        ]


selectJokesterView : Jokester -> Html Msg
selectJokesterView ((Jokester name _) as jokester) =
    button
        [ class "jokester-select"
        , onClick <| UserSelectedJokester jokester
        ]
        [ span [ class "name" ] [ text name ], span [ class "right-caret" ] [ text ">" ] ]


writeJokeView : Jokester -> String -> Html Msg
writeJokeView j s =
    div [ class "write-joke-view" ]
        [ h1 [] [ plopInName j ]
        , textarea [ onInput WriteJokeTypings, class "textarea", value s ] []
        , button [ class "submit-button", onClick UserClickedSubmitJoke ] [ text "submit" ]
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
        , subscriptions = always Sub.none
        }
