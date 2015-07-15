<?php

namespace RecipeSearchSimple;

class Util {
    public static function recipeTitleToId($recipeTitle)
    {
        return preg_replace('/[^\w]+/', '-', strtolower($recipeTitle));
    }

    public static function recipeTagsToArray($recipeTags)
    {
        $tags = [];
        foreach (explode(",", $recipeTags) as $tag) {
          $tags[] = trim($tag);
        }
        return $tags;
    }
}
