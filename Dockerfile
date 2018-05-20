FROM elixir

RUN mkdir app 
COPY . .
RUN rm -rf _build mix deps stuff
RUN mix local.rebar --force
RUN yes | mix deps.get
RUN mix compile

CMD ["mix", "run", "--no-halt"]
