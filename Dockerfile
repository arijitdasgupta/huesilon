FROM elixir

RUN mkdir app 
COPY . .
RUN rm -rf _build deps usernames.txt
RUN mix local.rebar --force
RUN yes | mix deps.get
RUN mix compile

CMD ["mix", "run", "--no-halt"]
