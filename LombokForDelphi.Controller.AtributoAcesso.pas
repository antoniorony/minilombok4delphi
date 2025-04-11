unit LombokForDelphi.Controller.AtributoAcesso;

interface

type
  AtributoDeAcesso = class(TCustomAttribute)
  end;

  NotNull = class(TCustomAttribute)
    private
      FNotNull : Boolean;
    public
      constructor Create(ENotNull : Boolean);
      function ENotNull : Boolean;
  end;

implementation

{ NotNull }

constructor NotNull.Create(ENotNull : Boolean);
begin
  FNotNull := ENotNull;
end;

function NotNull.ENotNull: Boolean;
begin
  Result := FNotNull;
end;

end.
