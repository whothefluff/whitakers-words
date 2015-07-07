-- WORDS, a Latin dictionary, by Colonel William Whitaker (USAF, Retired)
--
-- Copyright William A. Whitaker (1936–2010)
--
-- This is a free program, which means it is proper to copy it and pass
-- it on to your friends. Consider it a developmental item for which
-- there is no charge. However, just for form, it is Copyrighted
-- (c). Permission is hereby freely given for any and all use of program
-- and data. You can sell it as your own, but at least tell me.
--
-- This version is distributed without obligation, but the developer
-- would appreciate comments and suggestions.
--
-- All parts of the WORDS system, source code and data files, are made freely
-- available to anyone who wishes to use them, for whatever purpose.

separate (Dictionary_Package)
package body Dictionary_Entry_IO is
   use Part_Entry_IO;
   use Translation_Record_IO;
   --use KIND_ENTRY_IO;

   ---------------------------------------------------------------------------

   Spacer   : Character := ' ';
   Part_Col : Natural   := 0;

   ---------------------------------------------------------------------------

   procedure Get (File : in File_Type; Item : out Dictionary_Entry) is
   begin
      for K in Stem_Key_Type range 1 .. 4 loop
         Get (File, Item.Stems (K));
         Get (File, Spacer);
      end loop;

      Get(File, Item.Part);
      --    GET(F, SPACER);
      --    GET(F, D.PART.POFS, D.KIND);
      Get (File, Spacer);
      Get (File, Item.Tran);
      Get (File, Spacer);
      Get (File, Item.Mean);
   end Get;

   ---------------------------------------------------------------------------

   procedure Get (Item : out Dictionary_Entry) is
   begin
      for K in Stem_Key_Type range 1 .. 4 loop
         Get (Item.Stems (K));
         Get (Spacer);
      end loop;

      Get (Item.Part);
      --    GET(SPACER);
      --    GET(D.PART.POFS, D.KIND);
      Get (Spacer);
      Get (Item.Tran);
      Get (Spacer);
      Get (Item.Mean);
   end Get;

   ---------------------------------------------------------------------------

   procedure Put (File : in File_Type; Item : in Dictionary_Entry) is
   begin
      for K in Stem_Key_Type range 1 .. 4 loop
         Put (File, Item.Stems (K));
         Put (File, ' ');
      end loop;

      Part_Col := Natural (Col (File));
      Put (File, Item.Part);
      --    PUT(F, ' ');
      --    PUT(F, D.PART.POFS, D.KIND);
      Set_Col (File, Count (Part_Col + Part_Entry_IO.Default_Width + 1));
      Put (File, Item.Tran);
      Put (File, ' ');
      Put (File, Item.Mean);
   end Put;

   ---------------------------------------------------------------------------

   procedure Put (Item : in Dictionary_Entry) is
   begin
      for K in Stem_Key_Type range 1 .. 4 loop
         Put (Item.Stems (K));
         Put (' ');
      end loop;

      Part_Col := Natural (Col);
      Put (Item.Part);
      --    PUT(' ');
      --    PUT(D.PART.POFS, D.KIND);
      Set_Col (Count (Part_Col + Part_Entry_IO.Default_Width + 1));
      Put (Item.Tran);
      Put (' ');
      Put (Item.Mean);
   end Put;

   ---------------------------------------------------------------------------

   procedure Get
      ( Source : in  String;
        Target : out Dictionary_Entry;
        Last   : out Integer
      )
   is
      -- Used for computing lower bound of substring
      Low  : Integer := Source'First - 1;
      -- Used for computing Last
      High : Integer := 0;
   begin
      for K in Stem_Key_Type range 1 .. 4 loop
         Stem_Type_IO.Get
            ( Source (Low + 1 .. Source'Last),
              Target.Stems (K),
              Low
            );
      end loop;

      Get (Source (Low + 1 .. Source'Last), Target.Part, Low);
      --    L := L + 1;
      --    GET(S(L+1..S'LAST), D.PART.POFS, D.KIND, L);
      Low := Low + 1;
      Get (Source (Low + 1 .. Source'Last), Target.Tran, Low);
      Low := Low + 1;
      Target.Mean := Head (Source (Low + 1 .. Source'Last), Max_Meaning_Size);

      High := Low + 1;
      while Source (High) = ' ' loop
         High := High + 1;
      end loop;

      while (Source (High) not in 'A'..'Z') and
            (Source (High) not in 'a'..'z')
      loop
         Last := High;
         High := High + 1;
         -- FIXME: WTF???
         exit;
      end loop;
   end Get;

   ---------------------------------------------------------------------------

   procedure Put (Target : out String; Item : in Dictionary_Entry)
   is
      -- Used for computing bounds of substrings
      Low  : Integer := Target'First - 1;
      High : Integer := 0;
   begin
      -- Put Stem_Types
      for K in Stem_Key_Type range 1 .. 4 loop
         High := Low + Max_Stem_Size;
         Target (Low + 1 .. High) := Item.Stems (K);
         Low := High + 1;
         Target (Low) :=  ' ';
      end loop;

      -- Put Part_Entry
      Part_Col := Low + 1;
      High := Low + Part_Entry_IO.Default_Width;
      Put (Target (Low + 1 .. High), Item.Part);
      --    L := M + 1;
      --    S(L) :=  ' ';
      --    M := L + KIND_ENTRY_IO_DEFAULT_WIDTH;
      --    PUT(S(L+1..M), D.PART.POFS, D.KIND);

      -- Put Translation_Record
      Low  := Part_Col + Part_Entry_IO.Default_Width + 1;
      High := Low + Translation_Record_IO.Default_Width;
      Put (Target (Low + 1 .. High), Item.Tran);

      -- Put Meaning_Type
      Low := High + 1;
      Target (Low) :=  ' ';
      High := High + Max_Meaning_Size;
      Target (Low + 1 .. High) := Item.Mean;

      -- Fill remainder of string
      Target (High + 1 .. Target'Last) := (others => ' ');
   end Put;

   ---------------------------------------------------------------------------

end Dictionary_Entry_IO;
