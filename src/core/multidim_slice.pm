# all sub postcircumfix [;] candidates here please
proto sub postcircumfix:<[; ]>(|) is nodal { * }

sub MD-ARRAY-SLICE-ONE-POSITION(\SELF, \indices, \idx, int $dim, \target) is raw {
    my int $next-dim = $dim + 1;
    if $next-dim < indices.elems {
        if nqp::istype(idx, Iterable) && !nqp::iscont(idx) {
            for idx {
                MD-ARRAY-SLICE-ONE-POSITION(SELF, indices, $_, $dim, target)
            }
        }
        elsif nqp::istype(idx, Int) {
            MD-ARRAY-SLICE-ONE-POSITION(SELF.AT-POS(idx), indices, indices.AT-POS($next-dim), $next-dim, target)
        }
        elsif nqp::istype(idx, Whatever) {
            for ^SELF.cache.elems {
                MD-ARRAY-SLICE-ONE-POSITION(SELF.AT-POS($_), indices, indices.AT-POS($next-dim), $next-dim, target)
            }
        }
        elsif nqp::istype(idx, Callable) {
            MD-ARRAY-SLICE-ONE-POSITION(SELF, indices, idx.(|(SELF.cache.elems xx (idx.count == Inf ?? 1 !! idx.count))), $dim, target);
        }
        else  {
            MD-ARRAY-SLICE-ONE-POSITION(SELF.AT-POS(idx.Int), indices, indices.AT-POS($next-dim), $next-dim, target)
        }
    }
    else {
        if nqp::istype(idx, Iterable) && !nqp::iscont(idx) {
            for idx {
                MD-ARRAY-SLICE-ONE-POSITION(SELF, indices, $_, $dim, target)
            }
        }
        elsif nqp::istype(idx, Int) {
            nqp::push(target, SELF.AT-POS(idx))
        }
        elsif nqp::istype(idx, Whatever) {
            for ^SELF.cache.elems {
                nqp::push(target, SELF.AT-POS($_))
            }
        }
        elsif nqp::istype(idx, Callable) {
            nqp::push(target, SELF.AT-POS(idx.(|(SELF.cache.elems xx (idx.count == Inf ?? 1 !! idx.count)))))
        }
        else {
            nqp::push(target, SELF.AT-POS(idx.Int))
        }
    }
}
sub MD-ARRAY-SLICE(\SELF, @indices) is raw {
    my \target = IterationBuffer.new;
    MD-ARRAY-SLICE-ONE-POSITION(SELF, @indices, @indices.AT-POS(0), 0, target);
    nqp::p6bindattrinvres(nqp::create(List), List, '$!reified', target)
}

multi sub postcircumfix:<[; ]>(\SELF, @indices) is raw {
    nqp::if(
      (my int $elems = Rakudo::Internals.ALL_DEFINED_TYPE(@indices,Int)),
      nqp::if(
        nqp::iseq_i($elems,2),
        SELF.AT-POS(
          nqp::atpos(nqp::getattr(@indices,List,'$!reified'),0),
          nqp::atpos(nqp::getattr(@indices,List,'$!reified'),1)
        ),
        nqp::if(
          nqp::iseq_i($elems,3),
          SELF.AT-POS(
            nqp::atpos(nqp::getattr(@indices,List,'$!reified'),0),
            nqp::atpos(nqp::getattr(@indices,List,'$!reified'),1),
            nqp::atpos(nqp::getattr(@indices,List,'$!reified'),2)
          ),
          SELF.AT-POS(|@indices)
        )
      ),
      MD-ARRAY-SLICE(SELF,@indices),
    )
}

multi sub postcircumfix:<[; ]>(\SELF, @indices, Mu \assignee) is raw {
    nqp::if(
      (my int $elems = Rakudo::Internals.ALL_DEFINED_TYPE(@indices,Int)),
      nqp::if(
        nqp::iseq_i($elems,2),
        SELF.ASSIGN-POS(
          nqp::atpos(nqp::getattr(@indices,List,'$!reified'),0),
          nqp::atpos(nqp::getattr(@indices,List,'$!reified'),1),
          assignee
        ),
        nqp::if(
          nqp::iseq_i($elems,3),
          SELF.ASSIGN-POS(
            nqp::atpos(nqp::getattr(@indices,List,'$!reified'),0),
            nqp::atpos(nqp::getattr(@indices,List,'$!reified'),1),
            nqp::atpos(nqp::getattr(@indices,List,'$!reified'),2),
            assignee
          ),
          SELF.ASSIGN-POS(|@indices,assignee)
        )
      ),
      (MD-ARRAY-SLICE(SELF,@indices) = assignee),
    )
}

multi sub postcircumfix:<[; ]>(\SELF, @indices, :$exists!) is raw {
    nqp::if(
      $exists,
      nqp::if(
        (my int $elems = Rakudo::Internals.ALL_DEFINED_TYPE(@indices,Int)),
        nqp::if(
          nqp::iseq_i($elems,2),
          SELF.EXISTS-POS(
            nqp::atpos(nqp::getattr(@indices,List,'$!reified'),0),
            nqp::atpos(nqp::getattr(@indices,List,'$!reified'),1)
          ),
          nqp::if(
            nqp::iseq_i($elems,3),
            SELF.EXISTS-POS(
              nqp::atpos(nqp::getattr(@indices,List,'$!reified'),0),
              nqp::atpos(nqp::getattr(@indices,List,'$!reified'),1),
              nqp::atpos(nqp::getattr(@indices,List,'$!reified'),2)
            ),
            SELF.EXISTS-POS(|@indices)
          )
        ),
        Failure.new(X::NYI.new(
          feature => ':exists on multi-dimensional slices')),
      ),
      postcircumfix:<[; ]>(SELF, @indices)
    )
}

multi sub postcircumfix:<[; ]>(\SELF, @indices, :$delete!) is raw {
    nqp::if(
      $delete,
      nqp::if(
        (my int $elems = Rakudo::Internals.ALL_DEFINED_TYPE(@indices,Int)),
        nqp::if(
          nqp::iseq_i($elems,2),
          SELF.DELETE-POS(
            nqp::atpos(nqp::getattr(@indices,List,'$!reified'),0),
            nqp::atpos(nqp::getattr(@indices,List,'$!reified'),1)
          ),
          nqp::if(
            nqp::iseq_i($elems,3),
            SELF.DELETE-POS(
              nqp::atpos(nqp::getattr(@indices,List,'$!reified'),0),
              nqp::atpos(nqp::getattr(@indices,List,'$!reified'),1),
              nqp::atpos(nqp::getattr(@indices,List,'$!reified'),2)
            ),
            SELF.DELETE-POS(|@indices)
          )
        ),
        Failure.new(X::NYI.new(
          feature => ':delete on multi-dimensional slices')),
      ),
      postcircumfix:<[; ]>(SELF, @indices)
    )
}

multi sub postcircumfix:<[; ]>(\SELF, @indices, :$BIND!) is raw {
    nqp::if(
      (my int $elems = Rakudo::Internals.ALL_DEFINED_TYPE(@indices,Int)),
      nqp::if(
        nqp::iseq_i($elems,2),
        SELF.BIND-POS(
          nqp::atpos(nqp::getattr(@indices,List,'$!reified'),0),
          nqp::atpos(nqp::getattr(@indices,List,'$!reified'),1),
          $BIND
        ),
        nqp::if(
          nqp::iseq_i($elems,3),
          SELF.BIND-POS(
            nqp::atpos(nqp::getattr(@indices,List,'$!reified'),0),
            nqp::atpos(nqp::getattr(@indices,List,'$!reified'),1),
            nqp::atpos(nqp::getattr(@indices,List,'$!reified'),2),
            $BIND
          ),
          SELF.BIND-POS(|@indices, $BIND)
         )
      ),
      X::Bind::Slice.new(type => SELF.WHAT).throw,
    )
}

# vim: ft=perl6 expandtab sw=4