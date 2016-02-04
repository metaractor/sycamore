describe Sycamore::Tree do

  describe '#delete' do

    context 'when given an atomic value' do
      it 'does delete the value from the set of nodes' do
        expect( Sycamore::Tree[1] >> 1 ).to be_empty
        expect( Sycamore::Tree[1,2,3].delete(2).nodes.to_set ).to eq Set[1,3]
        expect( Sycamore::Tree[:foo, :bar].delete(:foo).size ).to be 1
      end

      it 'does nothing, when the given value is not present' do
        expect( Sycamore::Tree[1   ].delete(2    ) ).to include_node 1
        expect( Sycamore::Tree[:foo].delete('foo') ).to include_node :foo
      end

      context 'edge cases' do
        it 'does nothing, when given nil' do
          expect( Sycamore::Tree[1].delete(nil) ).to include_node 1
        end

        it 'does nothing, when given the Nothing tree' do
          expect( Sycamore::Tree[1].delete(Sycamore::Nothing) ).to include_node 1
        end

        it 'does treat false as key like any other value' do
          expect( Sycamore::Tree[false].delete(false)).to be_empty
        end
      end
    end

    context 'when given an array' do
      it 'does delete the values from the set of nodes that are present' do
        expect( Sycamore::Tree[1,2,3] >> [1,2,3] ).to be_empty
        expect( Sycamore::Tree[1,2,3] >> [2,3  ] ).to include 1
        expect( Sycamore::Tree[1,2,3].delete([2,3]).size ).to be 1
      end

      it 'does ignore the values that are not present' do
        expect( Sycamore::Tree.new  >> [1,2] ).to be_empty
        expect( Sycamore::Tree[1,2] >> [2,3] ).to include 1
        expect( Sycamore::Tree[1,2].delete([2,3]).size ).to be 1
      end

      context 'when the array is nested' do
        it 'does treat hashes as nodes with children' do
          expect( Sycamore::Tree[a: 1, b: 2     ].delete([:a, b: 2]) ).to be_empty
          expect( Sycamore::Tree[a: 1, b: [2, 3]].delete([:a, b: 2]) === {b: 3} ).to be true
        end

        it 'raises an error, when the nested enumerable is not Tree-like' do
          expect { Sycamore::Tree.new.delete([1, [2, 3]]) }.to raise_error Sycamore::InvalidNode
        end
      end

      context 'edge cases' do
        it 'does nothing, when given an empty array' do
          expect( Sycamore::Tree[1,2,3].delete([]).nodes.to_set ).to eq Set[1,2,3]
        end
      end
    end

    DELETE_TREE_EXAMPLES = [
      { before: {a: 1}           , delete: {a: 1}     , after: {} },
      { before: {a: [1, 2]}      , delete: {a: 2}     , after: {a: 1} },
      { before: {a: [1, 2]}      , delete: {a: [2]}   , after: {a: 1} },
      { before: {a: 1, b: [2,3]} , delete: {a:1, b:2} , after: {b: 3} },
      { before: {a: 1}           , delete: {a: Sycamore::Tree[1]} , after: {} },
      { before: {a: [1, 2]}      , delete: {a: Sycamore::Tree[2]} , after: {a: 1} },
    ]


    context 'when given a hash' do
      it 'does delete the given tree structure' do
        DELETE_TREE_EXAMPLES.each do |example|
          expect( Sycamore::Tree[example[:before]].delete(example[:delete]) )
            .to eql Sycamore::Tree[example[:after]]
        end
      end

      context 'edge cases' do
        it 'does treat false as key like any other value' do
          expect( Sycamore::Tree[false => 1].delete(false => 1) ).to be_empty
        end

        it 'does nothing, when given an empty hash' do
          expect( Sycamore::Tree.new >> {} ).to be_empty
        end

        it 'does nothing, when the key is nil' do
          expect( Sycamore::Tree[foo: 42] >> {nil => 42} ).to eq Sycamore::Tree[foo: 42]
        end

        it 'does ignore null values as children' do
          expect(Sycamore::Tree[1 => 2].delete({1 => Sycamore::Nothing})).to be_empty
          expect(Sycamore::Tree[1 => 2].delete({1 => nil})).to be_empty
          expect(Sycamore::Tree[1 => 2].delete({1 => {}})).to be_empty
          expect(Sycamore::Tree[1     ].delete({1 => []})).to be_empty
        end

        it 'does raise an error, when given a tree with an enumerable key' do
          expect { Sycamore::Tree.new.delete([1,2] => 3) }.to raise_error Sycamore::InvalidNode
          expect { Sycamore::Tree.new.delete({1 => 2} => 3) }.to raise_error Sycamore::InvalidNode
          expect { Sycamore::Tree.new.delete(Sycamore::Tree[1] => 42) }.to raise_error Sycamore::InvalidNode
          expect { Sycamore::Tree.new.delete(Sycamore::Nothing => 42) }.to raise_error Sycamore::InvalidNode
        end
      end
    end

    context 'when given a tree' do
      it 'does delete the given tree structure' do
        DELETE_TREE_EXAMPLES.each do |example|
          expect( Sycamore::Tree[example[:before]]
                    .delete(Sycamore::Tree[example[:delete]]) )
            .to eql Sycamore::Tree[example[:after]]
        end
      end

      context 'edge cases' do
        it 'does nothing, when given an empty tree' do
          expect( Sycamore::Tree[42] >> Sycamore::Tree.new ).to eq Sycamore::Tree[42]
        end

        context 'when given an Absence' do
          let(:absent_tree) { Sycamore::Tree.new.child_of(:something) }

          it 'does ignore it, when it is absent' do
            expect( Sycamore::Tree[:something].delete absent_tree ).to include :something
            expect( Sycamore::Tree[foo: :something].delete(foo: absent_tree)).to be_empty
          end

          it 'does treat it like a normal tree, when it was created' do
            absent_tree << 42

            expect( Sycamore::Tree[42].delete absent_tree ).to be_empty
            expect( Sycamore::Tree[foo: 42].delete(foo: absent_tree)).to be_empty
            expect( Sycamore::Tree[foo: [42, 3.14]].delete(foo: absent_tree)).to eq Sycamore::Tree[foo: 3.14]
          end
        end

        it 'does ignore null values as children' do
          expect(Sycamore::Tree[1 => 2].delete(Sycamore::Tree[1 => Sycamore::Nothing])).to be_empty
          expect(Sycamore::Tree[1 => 2].delete(Sycamore::Tree[1 => nil])).to be_empty
          expect(Sycamore::Tree[1 => 2].delete(Sycamore::Tree[1 => {}])).to be_empty
          expect(Sycamore::Tree[1     ].delete(Sycamore::Tree[1 => []])).to be_empty
        end
      end
    end

  end

  ############################################################################

  describe '#clear' do
    it 'does nothing when empty' do
      expect( Sycamore::Tree.new.clear.size  ).to be 0
      expect( Sycamore::Tree.new.clear.nodes ).to eq []
    end

    it 'does delete all nodes and their children' do
      expect( Sycamore::Tree[1, 2      ].clear.size  ).to be 0
      expect( Sycamore::Tree[:foo, :bar].clear.nodes ).to eq []
    end
  end

end
