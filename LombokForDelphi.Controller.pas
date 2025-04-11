unit LombokForDelphi.Controller;

interface

uses
  System.Classes, System.Rtti, System.TypInfo, System.JSON, System.Generics.Collections;

type
  TObjectHelper = class helper for TObject
    public
    function GetPropValueByName(const APropName: string): TValue;
    procedure SetPropValueByName(const APropName: string; const AValue: TValue);
    function GetFieldByName(const FieldName : string) : TValue;
    function SetFieldValueByName(const FieldName: string; const AValue: TValue) : TObject;
    function AllToString() : String;
    function AllToJson() : String;
  end;


implementation

uses
  System.SysUtils, LombokForDelphi.Controller.AtributoAcesso;

{ TObjectHelper }

function TObjectHelper.AllToJson: String;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Field: TRttiField;
  JsonObjeto : TJSONObject;
begin
  JsonObjeto := TJSONObject.Create;
  Contexto := TRttiContext.Create;
  try
    Tipo := Contexto.GetType(Self.ClassType);
    for Field in Tipo.GetFields do
      begin
        if Field.Name.Equals('FRefCount') then
          Continue;

        case Field.FieldType.TypeKind of
          tkUnknown: ;
          tkInteger: JsonObjeto.AddPair(Field.Name, Field.GetValue(Self).AsInteger);
          tkChar: ;
          tkEnumeration: ;
          tkFloat: JsonObjeto.AddPair(Field.Name, StrToFloat(Field.GetValue(Self).AsCurrency.ToString));
          tkString: JsonObjeto.AddPair(Field.Name, Field.GetValue(Self).AsString);
          tkSet: ;
          tkClass: ;
          tkMethod: ;
          tkWChar: ;
          tkLString: ;
          tkWString: ;
          tkVariant: ;
          tkArray: ;
          tkRecord: ;
          tkInterface: ;
          tkInt64: ;
          tkDynArray: ;
          tkUString: JsonObjeto.AddPair(Field.Name, Field.GetValue(Self).AsString);
          tkClassRef: ;
          tkPointer: ;
          tkProcedure: ;
          tkMRecord: ;
        end;
      end;
      
    Result := JsonObjeto.ToJSON;
  finally
    JsonObjeto.Free;
    Contexto.Free;
  end;
end;

function TObjectHelper.AllToString: String;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Field: TRttiField;
  ListaDeStrings : TList<String>;
  StringLocal : String;
begin
  Contexto := TRttiContext.Create;
  ListaDeStrings := TList<String>.Create;
  try
    Tipo := Contexto.GetType(Self.ClassType);

    for Field in Tipo.GetFields do
      begin
        if Field.Name.Equals('FRefCount') then
          Continue;
        
        case Field.FieldType.TypeKind of
          tkUnknown: ;
          tkInteger: ListaDeStrings.Add(Field.Name + ' : ' + Field.GetValue(Self).AsInteger.ToString);
          tkChar: ;
          tkEnumeration: ;
          tkFloat: ListaDeStrings.Add(Field.Name + ' : ' + Field.GetValue(Self).AsCurrency.ToString);
          tkString: ListaDeStrings.Add(Field.Name + ' : ' + Field.GetValue(Self).AsString); 
          tkSet: ;
          tkClass: ;
          tkMethod: ;
          tkWChar: ;
          tkLString: ;
          tkWString: ;
          tkVariant: ;
          tkArray: ;
          tkRecord: ;
          tkInterface: ;
          tkInt64: ;
          tkDynArray: ;
          tkUString: ListaDeStrings.Add(Field.Name + ' : ' + Field.GetValue(Self).AsString);
          tkClassRef: ;
          tkPointer: ;
          tkProcedure: ;
          tkMRecord: ;
        end;
      end;

    for StringLocal in ListaDeStrings do
      Result := Result + StringLocal + ',' + sLineBreak;

    Result := Copy(Result, 1, Length(Result) - 1);
      
  finally
    Contexto.Free;
    ListaDeStrings.Free;
  end;
end;

function TObjectHelper.GetFieldByName(const FieldName: string): TValue;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Field: TRttiField;
begin
  Contexto := TRttiContext.Create;
  try
    Tipo := Contexto.GetType(Self.ClassType);
    Field := Tipo.GetField(FieldName);

    if Assigned(Field) and Field.IsReadable then
      Result := Field.GetValue(Self)
    else
      raise Exception.Create('Field not found or not readable: ' + FieldName);
  finally
    Contexto.Free;
  end;
end;

function TObjectHelper.GetPropValueByName(const APropName: string): TValue;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Propriedade: TRttiProperty;
begin
  Contexto := TRttiContext.Create;
  try
    Tipo := Contexto.GetType(Self.ClassType);
    Propriedade := Tipo.GetProperty(APropName);

    if Assigned(Propriedade) and Propriedade.IsReadable then
      Result := Propriedade.GetValue(Self)
    else
      raise Exception.Create('Property not found or not readable: ' + APropName);
  finally
    Contexto.Free;
  end;
end;

function TObjectHelper.SetFieldValueByName(const FieldName: string;
  const AValue: TValue): TObject;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Field: TRttiField;
begin
  Result := Self;

  Contexto := TRttiContext.Create;
  try
    Tipo := Contexto.GetType(Self.ClassType);
    Field := Tipo.GetField(FieldName);

    if Assigned(Field) and Field.IsWritable then
      begin
        if (Length(Field.GetAttributes) > 0) and
           (Field.GetAttribute<NotNull>.ENotNull) and
           ((AValue.Kind = tkUString) or (AValue.Kind = tkString)) then
        begin
          if AValue.AsString.IsEmpty then
            raise Exception.Create('Campo n�o pode ser null');
        end;

        try
          case Field.FieldType.TypeKind of
            tkInteger : Field.SetValue(Self, StrToInt(AValue.AsString));
            tkString,
            tkUString : Field.SetValue(Self, AValue.AsString);
            tkFloat : Field.SetValue(Self, StrToFloat(AValue.AsString));
          end;
        except
          raise Exception.Create('Tipo n�o convencionado.');
        end;

      end
    else
      raise Exception.Create('Field not found or not writable: ' + FieldName);
  finally
    Contexto.Free;
  end;
end;

procedure TObjectHelper.SetPropValueByName(const APropName: string;
  const AValue: TValue);
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Propriedade: TRttiProperty;
begin
  Contexto := TRttiContext.Create;
  try
    Tipo := Contexto.GetType(Self.ClassType);
    Propriedade := Tipo.GetProperty(APropName);

    if Assigned(Propriedade) and Propriedade.IsWritable then
      Propriedade.SetValue(Self, AValue)
    else
      raise Exception.Create('Property not found or not writable: ' + APropName);
  finally
    Contexto.Free;
  end;
end;

end.
