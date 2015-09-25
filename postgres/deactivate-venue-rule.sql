CREATE RULE deactive_venue AS ON DELETE TO venues DO INSTEAD
  UPDATE venues
  SET active = false
  WHERE name = OLD.name;
